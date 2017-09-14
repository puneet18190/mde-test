require 'media'
require 'media/video'
require 'media/video/editing'
require 'media/in_tmp_dir'
require 'media/logging'
require 'media/error'
require 'media/video/editing/parameters'
require 'media/queue'
require 'media/video/editing/crop'
require 'media/video/editing/text_to_video'
require 'media/video/editing/image_to_video'
require 'media/video/editing/concat'
require 'media/audio'

module Media
  module Video
    module Editing
      # Compose the components supplied (videos, text, images) in order to create a new video based on them
      class Composer

        include InTmpDir
        include Logging

        # Composing processings main log folder
        def self.log_folder
          super 'composings'
        end

        # Create a new Media::Video::Editing::Composer instance, which processes video composings. +params+ should be created using Media::Video::Editing::Parameters#convert_to_primitive_parameters . Example of the +params+ hash:
        #
        #  {
        #    :initial_video => {
        #      :id => 123 # initial video id
        #    },
        #    :audio_track_id => audio_track_id, # audio track id (can be nil),

        #    # video components (the components which will be manipulated in order to produce the new video)
        #    :components => [
        #      {
        #        :type => Media::Video::Editing::Parameters::VIDEO_COMPONENT, # component type (one between Media::Video::Editing::Parameters::COMPONENTS)
        #        :video => 321 # video id
        #        :from => 12, # start of the video in seconds (the new video will contain the video component starting from this second)
        #        :to => 24, # end of the video in seconds (the new video will contain the video component ending to this second)
        #      },
        #      {
        #        :type => Media::Video::Editing::Parameters::TEXT_COMPONENT, # as above
        #        :content => 'Some text', # Contents of the text which will be converted to video
        #        :duration => 14, # Duration of the displaying
        #        :background_color => 'red', # Background color
        #        :text_color => 'white' # Text color
        #      },
        #      {
        #        :type => Media::Video::Editing::Parameters::IMAGE_COMPONENT, # as above
        #        :image => 456, # image id which will be converted to video
        #        :duration => 2 # Duration of the displaying
        #      }
        #    ]
        #  }
        def initialize(params)
          @params = params
        end

        # Execute the composing processing; if it works, a success notification will be sent to the user; otherwise a fail notification will be sent to the user and the media record will be destroyed
        def run
          @old_media = video.media.try(:dup)
          compose
          @old_media.paths.values.each{ |p| FileUtils.rm_f p } if @old_media
        rescue StandardError => e
          if @old_media
            video.media     = @old_media.to_hash
            video.converted = true
            if old_fields = video.try(:metadata).try(:old_fields)
              video.title       = old_fields['title'] if old_fields['title'].present?
              video.description = old_fields['description'] if old_fields['description'].present?
              video.tags        = old_fields['tags'] if old_fields['tags'].present?
            end
            video.save!
            video.enable_lessons_containing_me
            Notification.send_to(
              video.user_id,
              I18n.t('notifications.video.compose.update.failed.title'),
              I18n.t('notifications.video.compose.update.failed.message', :item => video.title, :link => ::Video::CACHE_RESTORE_PATH),
              ''
            )
          else
            video.destroyable_even_if_not_converted = true
            video.destroy
            Notification.send_to(
              video.user_id,
              I18n.t('notifications.video.compose.create.failed.title'),
              I18n.t('notifications.video.compose.create.failed.message', :item => video.title, :link => ::Video::CACHE_RESTORE_PATH),
              ''
            )
          end

          raise e
        end

        # Composing of a single component
        def compose
          create_log_folder
          in_tmp_dir do
            concats = {}

            Queue.run *@params[:components].each_with_index.map { |component, i|
              proc {
                concats.store i,
                  case component[:type]
                  when Parameters::VIDEO_COMPONENT
                    compose_video *component.values_at(:video, :from, :to), i
                  when Parameters::IMAGE_COMPONENT
                    compose_image *component.values_at(:image, :duration), i
                  when Parameters::TEXT_COMPONENT
                    compose_text *component.values_at(:content, :duration, :text_color, :background_color), i
                  else
                    raise Error.new("wrong component type", type: component[:type])
                  end
              }
            }

            concats_sorted = concats.sort
            Queue.run *concats_sorted[0, concats_sorted.size-1].map { |i, concat|
              next_i = i+1
              next_concat = concats_sorted[next_i][1]
              proc {
                transition_i = (i+next_i)/2.0
                concats.store transition_i, Transition.new(concat, next_concat, tmp_path(transition_i.to_s), log_folder('transitions', transition_i.to_s)).run
              }
            }

            concat = tmp_path 'concat'
            outputs = Concat.new(concats.sort.map{ |_,c| c }, concat, log_folder('concat')).run

            if audio
              audios = Hash[ Media::Audio::FORMATS.map{ |f| [f, audio.media.path(f)] } ]
              outputs = ReplaceAudio.new(outputs, audios, tmp_path('replace_audio'), log_folder('replace_audio')).run
            end

            video.media               = outputs.merge(filename: video.title)
            video.composing           = nil
            video.metadata.old_fields = nil

            ActiveRecord::Base.transaction do
              video.save!
              video.enable_lessons_containing_me
              Notification.send_to(
                video.user_id,
                I18n.t("notifications.video.compose.#{notification_translation_key}.ok.title"),
                I18n.t("notifications.video.compose.#{notification_translation_key}.ok.message", :item => video.title),
                ''
              )
              video.user.video_editor_cache!
            end
          end
        end

        private
        # Instance-relative log folder
        def log_folder(*folders)
          File.join(@log_folder, *folders)
        end

        # Instance-model-thread relative log folder
        def log_folder_name
          File.join self.class.log_folder, video.id.to_s, "#{Time.now.utc.strftime("%Y-%m-%d_%H-%M-%S")}_#{::Thread.main.object_id}"
        end

        # Create the log folder
        def create_log_folder
          @log_folder = FileUtils.mkdir_p(log_folder_name).first
        end

        # Text component composing
        def compose_text(text, duration, color, background_color, i)
          text_file = Pathname.new tmp_path "text_#{i}.txt"
          text_file.open('w') { |f| f.write text }
          TextToVideo.new(text_file, output_without_extension(i), duration, { color: color, background_color: background_color }, log_folder('components', "#{i}_text")).run
        end

        # Image component composing
        def compose_image(image_id, duration, i)
          image = ::Image.find image_id
          ImageToVideo.new(image.media.path, output_without_extension(i), duration, log_folder('components', "#{i}_image")).run
        end

        # Video component composing
        def compose_video(video_id, from, to, i)
          video = ::Video.find video_id
          inputs = Hash[ FORMATS.map{ |f| [f, video.media.path(f)] } ]

          if from == 0 && to == video.min_duration
            {}.tap do |outputs|
              Queue.run *inputs.map { |format, input| proc { video_copy input, (outputs[format] = "#{output_without_extension(i)}.#{format}") } }
            end
          else
            start, duration = from, to-from
            Crop.new(inputs, output_without_extension(i), start, duration, log_folder('components', "#{i}_video")).run
          end
        end

        # Locale key depending of the composing action type
        def notification_translation_key
          @old_media ? 'update' : 'create'
        end

        # Video file copy
        def video_copy(input, output)
          if audio
            # scarto gli stream audio, così poi non perdo tempo a processare le tracce audio inutilmente
            Cmd::VideoStreamToFile.new(input, output).run!
          else
            FileUtils.cp(input, output)
          end
        end

        # Temporary output path without extension
        def output_without_extension(i)
          tmp_path i.to_s
        end

        # Initial video instance
        def video
          @video ||= ::Video.find @params[:initial_video][:id]
        end

        # Audio track instance (+nil+ if <tt>params[:id]</tt> is not provided)
        def audio
          @audio ||= (
            id = @params[:audio_track]
            ::Audio.find(id) if id
          )
        end
      end
    end
  end
end

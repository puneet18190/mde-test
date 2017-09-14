require 'media'
require 'media/audio'
require 'media/audio/editing'
require 'media/in_tmp_dir'
require 'media/queue'
require 'media/audio/editing/crop'
require 'media/audio/editing/concat'

module Media
  module Audio
    module Editing
      # Compose the components supplied (audios) in order to create a new audio based on them
      class Composer

        include InTmpDir
        include Logging

        # Composing processings main log folder
        def self.log_folder
          super 'composings'
        end

        # Create a new Media::Audio::Editing::Composer instance, which processes audio composings. +params+ should be created using Media::Audio::Editing::Parameters#convert_to_primitive_parameters . Example of the +params+ hash:
        #
        #  {
        #    :initial_audio => 12 # initial audio id,
        #    :components => [
        #      {
        #        :audio => 123, # audio id
        #        :from => 12, # start of the audio in seconds (the new audio will contain the audio component starting from this second)
        #        :to => 24 # end of the audio in seconds (the new audio will contain the audio component ending to this second)
        #      },
        #      {
        #        # etc...
        #      }
        #    ]
        #  }
        def initialize(params)
          @params = params
        end

        # Execute the composing processing; if it works, a success notification will be sent to the user; otherwise a fail notification will be sent to the user and the media record will be destroyed
        def run
          @old_media = audio.media.try(:dup)
          compose
          @old_media.paths.values.each{ |p| FileUtils.rm_f p } if @old_media
        rescue StandardError => e
          if @old_media
            audio.media     = @old_media.to_hash
            audio.converted = true
            if old_fields = audio.try(:metadata).try(:old_fields)
              audio.title       = old_fields['title'] if old_fields['title'].present?
              audio.description = old_fields['description'] if old_fields['description'].present?
              audio.tags        = old_fields['tags'] if old_fields['tags'].present?
            end
            audio.save!
            audio.enable_lessons_containing_me
            Notification.send_to(
              audio.user_id,
              I18n.t('notifications.audio.compose.update.failed.title'),
              I18n.t('notifications.audio.compose.update.failed.message', :item => audio.title, :link => ::Audio::CACHE_RESTORE_PATH),
              ''
            )
          else
            audio.destroyable_even_if_not_converted = true
            audio.destroy
            Notification.send_to(
              audio.user_id,
              I18n.t('notifications.audio.compose.create.failed.title'),
              I18n.t('notifications.audio.compose.create.failed.message', :item => audio.title, :link => ::Audio::CACHE_RESTORE_PATH),
              ''
            )
          end
          raise e
        end

        # Composing of a single component
        def compose
          create_log_folder
          in_tmp_dir do
            concats = {}.tap do |concats|
              Queue.run *@params[:components].each_with_index.map { |component, i|
                proc{ concats.store i, compose_audio(*component.values_at(:audio, :from, :to), i) }
              }
            end

            concat = tmp_path 'concat'
            outputs = Concat.new(concats.sort.map{ |_, c| c }, concat, log_folder('concat')).run

            audio.media               = outputs.merge(filename: audio.title)
            audio.composing           = nil
            audio.metadata.old_fields = nil

            ActiveRecord::Base.transaction do
              audio.save!
              audio.enable_lessons_containing_me
              Notification.send_to(
                audio.user_id,
                I18n.t("notifications.audio.compose.#{notification_translation_key}.ok.title"),
                I18n.t("notifications.audio.compose.#{notification_translation_key}.ok.message", :item => audio.title),
                ''
              )
              audio.user.audio_editor_cache!
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
          File.join self.class.log_folder, audio.id.to_s, "#{Time.now.utc.strftime("%Y-%m-%d_%H-%M-%S")}_#{::Thread.main.object_id}"
        end

        # Create the log folder
        def create_log_folder
          @log_folder = FileUtils.mkdir_p(log_folder_name).first
        end

        # Audio component composing
        def compose_audio(audio_id, from, to, i)
          audio = ::Audio.find audio_id
          inputs = Hash[ FORMATS.map{ |f| [f, audio.media.path(f)] } ]

          if from == 0 && to == audio.min_duration
            {}.tap do |outputs|
              Queue.run *inputs.map { |format, input| proc { audio_copy input, (outputs[format] = "#{output_without_extension(i)}.#{format}") } }
            end
          else
            start, duration = from, to-from
            Crop.new(inputs, output_without_extension(i), start, duration, log_folder('crop', i.to_s)).run
          end
        end

        # Audio file copy
        def audio_copy(input, output)
          FileUtils.cp(input, output)
        end

        # Locale key depending of the composing action type
        def notification_translation_key
          @old_media ? 'update' : 'create'
        end

        # Temporary output path without extension
        def output_without_extension(i)
          tmp_path i.to_s
        end

        # Initial audio instance
        def audio
          @audio ||= ::Audio.find @params[:initial_audio][:id]
        end

      end
    end
  end
end

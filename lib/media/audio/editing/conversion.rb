require 'media'
require 'media/audio'
require 'media/audio/editing'
require 'media/logging'
require 'media/similar_durations'
require 'media/info'
require 'media/error'
require 'media/audio/editing/cmd/conversion'
require 'env_relative_path'

module Media
  module Audio
    module Editing
      # Convert an audio to formats playable by HTML5 capable browsers
      class Conversion

        include EnvRelativePath
        include Logging
        include SimilarDurations

        # Temporary conversion files folder path
        TEMP_FOLDER        = Rails.root.join(env_relative_path('tmp/media/audio/editing/conversions')).to_s
        # Maximum duration difference between two converted files allowed
        DURATION_THRESHOLD = CONFIG.duration_threshold

        # Remove the temporary folder
        def self.remove_folder!
          FileUtils.rm_rf TEMP_FOLDER
        end

        # Log files folder path
        def self.log_folder
          super 'conversions'
        end

        # Model-relative temporary folder path
        def self.temp_folder(model_id)
          File.join TEMP_FOLDER, model_id.to_s
        end

        # Model-relative temporary file path
        def self.temp_path(model_id, original_filename)
          File.join temp_folder(model_id), original_filename
        end

        # Id of the model to be converted
        attr_reader :model_id
        # Uploaded file path
        attr_reader :uploaded_path

        # Create a new Media::Audio::Editing::Conversion instance
        #
        # ### Arguments
        #
        # * *uploaded_path*: path to the file to be converted. The file will be moved to the temporary path and removed after the conversion
        # * *output_path_without_extension*: output path without the extension (it will be added automatically by the conversion for each output format)
        #
        # ### Examples
        #
        #   Media::Audio::Editing::Conversion.new('/tmp/path.abcdef', '/path/to/desy/public/media_elements/13/valid-audio', 'valid audio.flv', 13)
        def initialize(uploaded_path, output_path_without_extension, original_filename, model_id)
          @model_id = model_id
          init_model

          @uploaded_path                 = uploaded_path
          @output_path_without_extension = output_path_without_extension
          @original_filename             = original_filename
        end

        # Execute the conversion processing: it converts the media the output formats and sends a notification of success to the user who uploaded the file. If an error occurs, destroys the record and sends a notification of failure the user who uploaded the file.
        def run
          begin
            prepare_for_conversion

            Queue.run *FORMATS.map{ |format| proc{ convert_to(format) } }, close_connection_before_execution: true

            m4a_file_info = Info.new output_path(:m4a)
            ogg_file_info = Info.new output_path(:ogg)

            unless similar_durations?(m4a_file_info.duration, ogg_file_info.duration) 
              raise Error.new( 'output audios have different duration', 
                               model_id: model_id, m4a_duration: m4a_file_info.duration, ogg_duration: ogg_file_info.duration )
            end

          rescue StandardError => e
            FileUtils.rm_rf output_folder
            
            input_path = 
              if File.exists? temp_path
                temp_path
              elsif File.exists? uploaded_path
                uploaded_path
              end
            FileUtils.cp input_path, create_log_folder if input_path

            if model.present? and model.user_id.present?
              Notification.send_to(
                model.user_id,
                I18n.t('notifications.audio.upload.failed.title'),
                I18n.t('notifications.audio.upload.failed.message', :item => model.title),
                ''
              )
              model.destroyable_even_if_not_converted = true
              model.destroy
            end

            raise e
          end

          model.converted    = true
          model.rename_media = true
          model.m4a_duration = m4a_file_info.duration
          model.ogg_duration = ogg_file_info.duration
          model.media        = output_filename_without_extension
          model[:media]      = output_filename_without_extension
          model.save!

          FileUtils.rm temp_path
          
          Notification.send_to(
            model.user_id,
            I18n.t('notifications.audio.upload.ok.title'),
            I18n.t('notifications.audio.upload.ok.message', :item => model.title),
            ''
          )
        end

        # Manages the conversion processing
        def convert_to(format)
          prepare_for_conversion unless @prepare_for_conversion

          output_path = output_path(format)

          log_folder = create_log_folder
          stdout_log, stderr_log = stdout_log(format), stderr_log(format)

          Cmd::Conversion.new(temp_path, output_path, format).run! %W(#{stdout_log} a), %W(#{stderr_log} a)
        rescue StandardError => e
          FileUtils.rm_rf output_folder
          raise e
        end

        private
        # Prepares for the conversion processing
        def prepare_for_conversion
          if !File.exists?(uploaded_path) && !File.exists?(temp_path)
            raise Error.new( "at least one between uploaded_path and temp_path must exist", 
                             temp_path: temp_path, uploaded_path: uploaded_path)
          end

          FileUtils.mkdir_p temp_folder unless Dir.exists? temp_folder

          # If temp_path already exists, I assume that someone has already processed it before;
          # so I use it (I use it as cache)
          FileUtils.mv uploaded_path, temp_path unless File.exists? temp_path

          FileUtils.mkdir_p output_folder unless Dir.exists? output_folder

          @prepare_for_conversion = true
        end

        # Format-relative output path
        def output_path(format)
          "#{@output_path_without_extension}.#{format}"
        end

        # Uploaded path extension
        def uploaded_path_extension
          File.extname @uploaded_path
        end

        # Output filename without extension
        def output_filename_without_extension
          File.basename @output_path_without_extension
        end

        # Output folder path
        def output_folder
          File.dirname @output_path_without_extension
        end
  
        # Model-relative temporary path
        def temp_path
          self.class.temp_path(model_id, @original_filename)
        end
  
        # Temporary folder path
        def temp_folder
          File.dirname temp_path
        end

        # Model-relative log folder path (the argument is ignored, it is specified just for ancestor method compatibility)
        def log_folder(_ = nil)
          super model_id.to_s
        end

        # Model to be converted
        def model
          @model ||= ::Audio.find model_id
        end
        alias init_model model

      end
    end
  end
end

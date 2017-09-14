require 'media'
require 'media/video'
require 'media/video/uploader'

module Media
  module Video
    class Uploader
      # Module containing methods for validation of a Video
      module Validation
        # Adds the new errors to the original model
        def validation
          error_message = self.error_message
          model.errors.add :media, error_message if error_message
        end

        # Generates the error message
        def error_message
          if @converted_files
            error_message_for_converted_files
          elsif @original_file
            error_message_for_file_to_convert
          elsif @value.instance_of?(String)
            if column_changed? and not rename?
              'renaming denied'
            end
          else
            'unsupported upload'
          end
        end

        private
        
        # Error messages for an original file not yet converted
        def error_message_for_file_to_convert
          if not self.class::EXTENSION_WHITE_LIST_WITH_DOT.include?(original_filename_extension)
            'unsupported format'
          else
            info = Info.new(@original_file.path, false)
            if not info.valid?
              'invalid video'
            elsif info.video_streams.blank?
              'blank video streams'
            elsif info.duration < self.class::MIN_DURATION
              'invalid duration'
            end
          end
        end

        # Error message for already converted files
        def error_message_for_converted_files
          mp4_path, webm_path = @converted_files[:mp4], @converted_files[:webm]

          if !@original_filename_without_extension.is_a?(String)
            'invalid filename'
          elsif !mp4_path.instance_of?(String) || !webm_path.instance_of?(String)
            'invalid paths'
          elsif [mp4_path, webm_path].map{ |p| File.extname(p) } != %w(.mp4 .webm)
            'invalid extension'
          else

            mp4_duration, webm_duration = 
              if durations?
                [ durations[:mp4], durations[:webm] ]
              else
                if !(mp4_info = Info.new(mp4_path, false)).valid? || !(webm_info = Info.new(webm_path, false)).valid?
                  return 'invalid video'
                end
                [ mp4_info.duration, webm_info.duration ]
              end

            if [mp4_duration, webm_duration].min < self.class::MIN_DURATION
              'invalid duration'
            elsif !similar_durations?(mp4_duration, webm_duration)
              'invalid duration difference'
            end

          end
        end
      end
    end
  end
end

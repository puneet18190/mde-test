require 'media'
require 'media/audio'
require 'media/audio/uploader'

module Media
  module Audio
    class Uploader
      # Module containing methods to validate format of an audio
      module Validation
        # Method that adds the validation to the normal errors of the model Audio
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
          elsif @value.is_a?(String)
            if column_changed? && !rename?
              'renaming denied'
            end
          else
            'unsupported upload'
          end
        end

        private
        
        # Generates the error message for the original file not yet converted (a possible problem can be the wrong duration)
        def error_message_for_file_to_convert
          if not self.class::EXTENSION_WHITE_LIST_WITH_DOT.include?(original_filename_extension)
            'unsupported format'
          else
            info = Info.new(@original_file.path, false)
            if !info.valid?
              'invalid audio'
            elsif info.duration < self.class::MIN_DURATION
              'invalid duration'
            end
          end
        end

        # Generates the error messages for already converted files (invalid filename, invalid extension, etc)
        def error_message_for_converted_files
          m4a_path, ogg_path = @converted_files[:m4a], @converted_files[:ogg]
          if !@original_filename_without_extension.is_a?(String)
            'invalid filename'
          elsif !m4a_path.instance_of?(String) || !ogg_path.instance_of?(String)
            'invalid paths'
          elsif [m4a_path, ogg_path].map{ |p| File.extname(p) } != %w(.m4a .ogg)
            'invalid extension'
            else

              m4a_duration, ogg_duration = 
                if durations?
                  [ durations[:m4a], durations[:ogg] ]
                else
                  if !(m4a_info = Info.new(m4a_path, false)).valid? || !(ogg_info = Info.new(ogg_path, false)).valid?
                    return 'invalid video'
                  end
                  [ m4a_info.duration, ogg_info.duration ]
                end

              if [m4a_duration, ogg_duration].min < self.class::MIN_DURATION
                'invalid duration'
              elsif !similar_durations?(m4a_duration, ogg_duration)
                'invalid duration difference'
              end

            end

        end
      end
    end
  end
end

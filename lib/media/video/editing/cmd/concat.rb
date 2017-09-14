require 'media'
require 'media/video'
require 'media/video/editing'
require 'media/video/editing/cmd'
require 'media/error'

module Media
  module Video
    module Editing
      class Cmd
        # CLI for Media::Video::Editing::Concat processings, joins +video_input+ with +audio_input+ cutting the output to +duration+
        class Concat
          require 'media/video/editing/cmd/concat/mp4'
          require 'media/video/editing/cmd/concat/webm'

          # Returns a new descendant class instance depending on +format+
          def self.new(video_input, audio_input, duration, output, format)
            unless FORMATS.include? format
              raise Media::Error.new 'unsupported format', format: format
            end

            const_get(format.capitalize).new video_input, audio_input, duration, output
          end

        end
      end
    end
  end
end

require 'media'
require 'media/video'
require 'media/video/editing'
require 'media/video/editing/cmd'
require 'media/video/editing/cmd/avconv'
require 'shellwords'

module Media
  module Video
    module Editing
      class Cmd
        # CLI for converting an image to a video
        class ImageToVideo < Cmd::Avconv
          def initialize(input_file, output_file, format, duration)
            super([input_file], output_file, format)
  
            input_options  [ '-loop 1' ]
            output_options [ vcodec, "-t #{duration.round(2).to_s.shellescape}" ]
          end
  
          private
          # audio quality (not set)
          def qa
          end
        end
      end
    end
  end
end

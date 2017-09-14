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
        # CLI for exporting a video frame as image (avconv example: <tt>avconv -i input.webm -ss 38.70 -frames:v 1 frame.jpg</tt>)
        class ExtractFrame < Cmd::Avconv
  
          def initialize(input, output, _seek)
            @input, @output, @seek = input, output, _seek
            super [@input], @output
            output_options [ seek, vframes ]
          end
  
          private
          # Frame seek
          def seek
            "-ss #{@seek.to_s.shellescape}"
          end
  
          # Frames amount (1)
          def vframes
            "-frames:v 1"
          end
  
          # Video quality (not set)
          def qv
          end
  
          # Subtitles disabling (not set, unuseful)
          def sn
          end
  
        end
      end
    end
  end
end

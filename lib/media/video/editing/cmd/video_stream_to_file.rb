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
        # CLI for extracting a video track to a video file
        class VideoStreamToFile < Cmd::Avconv
          def initialize(input, output)
            @input, @output = input, output
          end
  
          private
          # Command string
          def cmd!
            %Q[ #{BIN}
                  #{global_options.join(' ')}
                  -i #{@input.shellescape}
                  -map 0:v:0
                  -c copy
                  #{@output.shellescape} ].squish
          end
        end
      end
    end
  end
end

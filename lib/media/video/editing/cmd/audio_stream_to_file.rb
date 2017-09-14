require 'media'
require 'media/video'
require 'media/video/editing'
require 'media/video/editing/cmd'
require 'shellwords'

module Media
  module Video
    module Editing
      class Cmd
        # CLI for exporting an audio stream from a video file to an audio file
        class AudioStreamToFile < Cmd::Avconv

          def initialize(input, output)
            @input, @output = input, output
          end
  
          private
          def cmd!
            %Q[ #{BIN}
                  #{global_options.join(' ')}
                  -i #{@input.shellescape}
                  -map 0:a:0
                  -c copy
                  #{@output.shellescape} ].squish
          end
        end
      end
    end
  end
end

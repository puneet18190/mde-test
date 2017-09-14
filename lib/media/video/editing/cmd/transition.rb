require 'media/video/editing'
require 'media/video/editing'
require 'media/video/editing/cmd'
require 'media/video/editing/cmd/avconv'
require 'shellwords'

module Media
  module Video
    module Editing
      class Cmd
        # CLI for creating video transitions from input transition frames (command example: <tt>avconv -r 25 -i ../transition-%d.jpg -c:v libx264 -q 1  transition.r25.mp4</tt>)
        class Transition < Cmd::Avconv
  
          def initialize(transitions, output, _frame_rate, format)
            @transitions, @output, @frame_rate, @format = transitions, output, _frame_rate, format
            super [@transitions], @output, format
            input_options  [ frame_rate ]
            output_options [ vcodec ]
          end
  
          private
          # Frame rate
          def frame_rate
            "-r #{@frame_rate.to_s.shellescape}"
          end
  
          # Audio quality (not set, unuseful)
          def qa
          end
  
        end
      end
    end
  end
end

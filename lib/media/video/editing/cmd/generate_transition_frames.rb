require 'media'
require 'media/video'
require 'media/video/editing'
require 'media/video/editing/cmd'
require 'shellwords'

module Media
  module Video
    module Editing
      class Cmd
        # CLI for generating transition frames given a starting frame and an ending frame (command line example: <tt>convert start_frame.jpg end_frame.jpg -morph 23 transition_frame-%d.jpg</tt>)
        class GenerateTransitionFrames < Cmd
  
          # ImageMagick convert executable
          BIN = IMAGEMAGICK_CONVERT_BIN.shellescape
  
          def initialize(start_frame, end_frame, frames_format, frames_amount)
            @start_frame, @end_frame, @frames_format, @frames_amount = start_frame, end_frame, frames_format, frames_amount
          end
  
          private
          # Command string
          def cmd!
            "#{BIN} #{start_frame} #{end_frame} -morph #{frames_amount} #{frames_format}"
          end
  
          # Start frame image path
          def start_frame
            @start_frame.shellescape
          end
  
          # End frame image path
          def end_frame
            @end_frame.shellescape
          end
  
          # Frames amount
          def frames_amount
            @frames_amount.to_s.shellescape
          end
  
          # Transition frames filename format
          def frames_format
            @frames_format.shellescape
          end
  
        end
      end
    end
  end
end

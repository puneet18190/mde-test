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
        # CLI for video cropping
        class Crop < Cmd::Avconv
          def initialize(input, output, _start, _duration, format)
            inputs = [input]
            super inputs, output, format
            @start, @duration = _start, _duration
            output_options [ vcodec, acodec, start, duration ]
          end
  
          private
          # Output video start seek
          def start
            "-ss #{@start.round(2).to_s.shellescape}"
          end
          # Output video duration
          def duration
            "-t #{@duration.round(2).to_s.shellescape}"
          end
        end
      end
    end
  end
end

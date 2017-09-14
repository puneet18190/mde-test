require 'media'
require 'media/video'
require 'media/video/editing'
require 'media/video/editing/cmd'
require 'media/video/editing/cmd/sox'
require 'shellwords'

# Per ora non è utilizzata, ma servirà in fase di editor audio
module Media
  module Video
    module Editing
      class Cmd
        # CLI for trimming an audio file
        class TrimAudioFile < Cmd::Sox
  
          def initialize(input, output, ltrim, rtrim)
            @input, @output, @ltrim, @rtrim = input, output, ltrim, rtrim
          end
  
          private
          # Command string
          def cmd!
            "#{BIN_AND_GLOBAL_OPTIONS} #{input} #{output} trim #{ltrim} #{rtrim}"
          end
  
          # input file path
          def input
            @input.shellescape
          end
  
          # output file path
          def output
            @output.shellescape
          end
  
          # left trim
          def ltrim
            shellescaped_trim(@ltrim)
          end
  
          # right trim
          def rtrim
            shellescaped_trim(@rtrim)
          end
  
          # Shell-escape a trim value
          def shellescaped_trim(value)
            value.round(2).to_s.shellescape
          end
  
        end
      end
    end
  end
end

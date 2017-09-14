require 'media'
require 'media/audio'
require 'media/audio/editing'
require 'media/audio/editing/cmd'
require 'media/audio/editing/cmd/sox'
require 'shellwords'

module Media
  module Audio
    module Editing
      class Cmd
        # CLI for Media::Audio::Editing::Concat processings, joins the audios producing one audio output
        class Concat < Cmd::Sox

          # Extensions not supported by sox
          UNSUPPORTED_FORMATS = [:m4a]
  
          # Instances a new Media::Audio::Editing::Cmd::Concat object
          #
          # ### Arguments
          #
          # * *audios_with_paddings*: audios with their possible relative paddings
          # * *output*: output path with the extension
          # * *format*: input files format
          #
          # ### Examples
          #
          #  Media::Audio::Editing::Cmd.new([ ['concat 0.wav', [1.234, 5.678] ], ['concat 1.wav', [8.765, 4.321] ] ], 'output.wav')
          #  Media::Audio::Editing::Cmd.new([ ['concat 0.m4a', [1.234, 5.678] ], ['concat 1.m4a', [8.765, 4.321] ] ], 'output.m4a', :m4a)
          def initialize(audios_with_paddings, output, format = nil)
            @audios_with_paddings, @output, @format = audios_with_paddings, output, format
          end
  
          private
          # Command string
          def cmd!
            output = @output.shellescape
            audios_with_paddings_length = @audios_with_paddings.length
  
            cmd_entries = @audios_with_paddings.each_with_index.map do |(audio, paddings), i|
              cmd_entry(audio.shellescape, output, audios_with_paddings_length, paddings, i)
            end

            # Shell command example:
            #  ( ( avconv -i c1.m4a -f sox - | sox -p -p pad 5 5) ; ( avconv -i c2.m4a -f sox - | sox -p -p pad 5 5 ); ( avconv -i c1.m4a -f sox - | sox -p pad 5 5 ) ; ( avconv -i c2.m4a -f sox - | sox -p -p pad 5 5 ) ) | sox -p -p | avconv -f sox -i - -strict experimental -c:a aac prova.m4a
            if unsupported_format?
              "( #{cmd_entries.join(' ; ')} ) | sox -p -p | avconv -f sox -i - -strict experimental -c:a aac #{output}"
            else
              cmd_entries.join(' | ')
            end
          end

          # Sub-command for each input entry; if the input format is not supported by Sox, uses avconv in order to convert the input to a sox pipe and passing it at sox, so it can add the pads
          def cmd_entry(input, output, audios_with_paddings_length, paddings, i)
            pad = sox_pad(paddings)

            if unsupported_format?
              pad_with_pipe = pad ? "| #{pad} " : ''
              "( avconv -i #{input} -f sox - #{pad_with_pipe})"
            else
              cmds = [ BIN_AND_GLOBAL_OPTIONS, sox_input(input, i), sox_output(output, audios_with_paddings_length, i) ]
              cmds << pad if pad
              cmds.join(' ')
            end
          end
  
          # Input option for Sox
          def sox_input(input, i)
            # If it is the first input it is a normal input, otherwise it is a sox pipe
            i == 0 ? input : "-p #{input}"
          end
  
          # Output option for Sox
          def sox_output(output, audios_with_paddings_length, i)
            # If it is the last input is is and audio pipe, otherwise it is a sox pipe
            i == audios_with_paddings_length-1 ? output : '-p'
          end

          # Pad option for Sox
          def sox_pad(paddings)
            if paddings
              lpad, rpad = paddings
              if lpad > 0 || rpad > 0
                lpad, rpad = lpad.round(2).to_s.shellescape, rpad.round(2).to_s.shellescape
                "pad #{lpad} #{rpad}"
              end
            end
          end

          # Whether the supplied format is supported by Sox or not
          def unsupported_format?
            case @format
            when *UNSUPPORTED_FORMATS then true
            else                           false
            end
          end
  
        end
      end
    end
  end
end

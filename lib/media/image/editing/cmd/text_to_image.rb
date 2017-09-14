require 'media'
require 'media/image'
require 'media/image/editing'
require 'media/image/editing/cmd'

module Media
  module Image
    module Editing
      class Cmd
        # Class that converts a text into an image, used for Video Editor (see VideoEditorController, Media::Video::Editing)
        class TextToImage < Cmd

          # Default options
          OPTIONS_AND_DEFAULTS = { width:            960, 
                                   height:           540, 
                                   color:            'black',
                                   background_color: 'white',
                                   font:             Rails.root.join('vendor/fonts/DroidSansFallback.ttf'), 
                                   gravity:          'Center', 
                                   pointsize:        48        }

          # Keys of the options
          OPTIONS = OPTIONS_AND_DEFAULTS.keys

          # The output
          attr_reader :output, *OPTIONS

          # The text can be a File, a Tempfile or a Pathname: if so, its contents will be used as text for the image
          def initialize(text, output, options = {})
            if (options.keys - OPTIONS).present?
              raise Error.new("options keys must be included into #{OPTIONS.inspect}")
            end

            @text, @output = text, output

            OPTIONS_AND_DEFAULTS.each do |option, default_value|
              instance_variable_set :"@#{option}", options[option] || default_value
            end
          end

          private
          
          # The shellescaped text
          def shellescaped_text
            case @text
            when File, Tempfile
              "@#{@text.path.shellescape}"
            when Pathname
              "@#{@text.to_s.shellescape}"
            else
              @text.to_s.shellescape
            end
          end

          # Command used in MiniMagick
          def cmd!
            %Q[ convert
                  -size       #{width.to_s.shellescape}x#{height.to_s.shellescape}
                  -background #{background_color.to_s.shellescape}
                  -fill       #{color.to_s.shellescape}
                  -font       #{font.to_s.shellescape}
                  -pointsize  #{pointsize.to_s.shellescape}
                  -gravity    #{gravity.to_s.shellescape}
                  label:#{shellescaped_text}
                  #{output.shellescape} ].squish
          end

        end
      end
    end
  end
end

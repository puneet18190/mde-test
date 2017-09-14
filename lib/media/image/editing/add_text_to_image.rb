require 'media'
require 'media/image'
require 'media/image/editing'
require 'media/image/editing/cmd'

module Media
  module Image
    module Editing
      # Class that contains the methods for adding multiple texts (see Image, ImageEditorController)
      class AddTextToImage < Cmd
        
        # Path of the font
        FONT_PATH = Rails.root.join('vendor/fonts/DroidSansFallback.ttf').to_s
        
        # Initializes the instance of this class; img is a mini_magick object
        def initialize(img, color_hex, font_size, coord_x, coord_y, text_value)
          @img, @color_hex, @font_size, @coord_x, @coord_y, @text = img, color_hex, font_size, coord_x, coord_y, text_value
        end
        
        private
        
        # Overwrites the method Media::Cmd#cmd! for this specific task
        def cmd!
        %Q[ mogrify
              -fill      #{@color_hex.to_s.shellescape}
              -stroke    none
              -font      #{FONT_PATH.shellescape}
              -pointsize #{@font_size.to_s.shellescape}
              -gravity   NorthWest
              -annotate  +#{@coord_x.to_i.to_s.shellescape}+#{@coord_y.to_i.to_s.shellescape} #{shellescaped_text}
              #{@img.to_s.shellescape} ].squish
        end
        
        # Extracts a shellescaped text
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
        
      end
    end
  end
end

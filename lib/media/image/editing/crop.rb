require 'media'
require 'media/image'
require 'media/image/editing'
require 'mini_magick'

module Media
  module Image
    module Editing
      # Class containing methods to crop an image
      class Crop
        
        # Initializes the crop
        def initialize(input, output, x1, y1, x2, y2)
          @input, @output = input, output

          @x1 = Editing.ratio_value mm_input[:width], mm_input[:height], x1
          @y1 = Editing.ratio_value mm_input[:width], mm_input[:height], y1
          @x2 = Editing.ratio_value mm_input[:width], mm_input[:height], x2
          @y2 = Editing.ratio_value mm_input[:width], mm_input[:height], y2
        end

        def mm_input
          @mm_input ||= MiniMagick::Image.open @input
        end
        
        # Runs the crop
        def run
          w = @x2.to_i - @x1.to_i
          h = @y2.to_i - @y1.to_i

          crop_params = "#{w}x#{h}+#{@x1.to_i}+#{@y1.to_i}"

          @mm_input.combine_options do |c|
            c.crop(crop_params)
            c << '+repage'
          end
          
          @mm_input.write @output
        end
        
      end
    end
  end
end

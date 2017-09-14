require 'media'
require 'media/image'
require 'media/image/editing'
require 'mini_magick'

module Media
  module Image
    module Editing
      # Resizes the image to fill the Image Editor
      class ResizeToFill
        
        # Initializer
        def initialize(input, output, width, height)
          @input, @output, @width, @height = input, output, width, height
        end
        
        # Runs the action
        def run
          input_image = ::MiniMagick::Image.open(@input)
          cols, rows = input_image[:dimensions]
          input_image.combine_options do |cmd|
            if @width != cols || @height != rows
              scale_x = @width/cols.to_f
              scale_y = @height/rows.to_f
              if scale_x >= scale_y
                cols = (scale_x * (cols + 0.5)).round
                rows = (scale_x * (rows + 0.5)).round
                cmd.resize "#{cols}"
              else
                cols = (scale_y * (cols + 0.5)).round
                rows = (scale_y * (rows + 0.5)).round
                cmd.resize "x#{rows}"
              end
            end
            cmd.gravity 'Center'
            cmd.background "rgba(255,255,255,0.0)"
            cmd.extent "#{@width}x#{@height}" if cols != @width || rows != @height
          end
          input_image.write(@output)
          @output
        end

      end
    end
  end
end

require 'media'
require 'media/image'

module Media
  module Image
    # Module containing logics for image editing
    module Editing

      # Ratio X      
      RATIO_X = 660.0

      # Ratio Y
      RATIO_Y = 500.0

      # ### Description
      #
      # Returns the original value of a coordinate, given the actual value and the size of the image
      #
      # ### Arguments
      #
      # * *w*: width of the image
      # * *h*: height of the image
      # * *value*: value to be scaled
      #
      # ### Returns
      #
      # A float.
      #
      def self.ratio_value(w, h, value)
        return value if h < RATIO_Y && w < RATIO_Y

        value.to_f *
          if ( w.to_f / h.to_f ) > ( RATIO_X / RATIO_Y )
            w / RATIO_X
          else
            h / RATIO_Y
          end
      end
    end
  end
end

require 'media/image/editing/cmd/text_to_image'

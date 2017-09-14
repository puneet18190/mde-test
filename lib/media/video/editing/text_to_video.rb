require 'media'
require 'media/video'
require 'media/video/editing'
require 'media/in_tmp_dir'
require 'media/image/editing/cmd/text_to_image'

module Media
  module Video
    module Editing
      # Convert a text to videos of the supplied duration
      class TextToVideo
  
        include InTmpDir

        # Media::Image::Editing::Cmd::TextToImage command options
        TEXT_TO_IMAGE_OPTIONS = Image::Editing::Cmd::TextToImage::OPTIONS

        # Text which will be displayed in the video
        attr_reader :text
        # Duration of the generated video
        attr_reader :duration
        # Media::Image::Editing::Cmd::TextToImage command options
        attr_reader *TEXT_TO_IMAGE_OPTIONS
  
        # Create a new Media::Video::Editing::TextToVideo instance
        #
        # ### Arguments
        #
        # * *text*: text which will be displayed in the video
        # * *output_without_extension*: output path without the extension
        # * *duration*: duration of the generated videos
        # * *options*: hash with the options to be passed to Media::Image::Editing::Cmd::TextToImage
        # * *log_folder* _optional_: log folder path
        #
        # ### Examples
        #
        #  Media::Video::Editing::TextToVideo.new('Hello', '/path/to/new/video/files', 3, { width: 100, height: 200 })
        def initialize(text, output_without_extension, duration, options = {}, log_folder = nil)
          unless output_without_extension.is_a?(String)
            raise Error.new('output_without_extension must be a String', output_without_extension: output_without_extension)
          end
  
          unless duration.is_a?(Numeric) and duration > 0
            raise Error.new('duration must be a Numeric > 0', duration: duration)
          end
  
          @text, @output_without_extension, @duration, @options = text, output_without_extension, duration, options

          @log_folder = log_folder
        end
  
        # Execute the video creation processing
        def run
          outputs = nil
  
          in_tmp_dir do
            image = tmp_path 'text_to_image.jpg'
            Image::Editing::Cmd::TextToImage.new(text, image, @options).run!

            outputs = ImageToVideo.new(image, @output_without_extension, duration, @log_folder).run
          end

          outputs
        end

      end
    end
  end
end

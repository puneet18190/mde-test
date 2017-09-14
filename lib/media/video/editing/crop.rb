require 'media'
require 'media/video'
require 'media/video/editing'
require 'media/video/editing/cmd/crop'
require 'media/logging'

module Media
  module Video
    module Editing
      # Crop the input videos supplied producing shorter output videos
      class Crop
  
        include Logging

        # Output formats
        FORMATS  = FORMATS
        # Crop command class (needed by Media::Audio::Editing::Crop which is a descendant of this class)
        CROP_CMD = Cmd::Crop
  
        # Create a new Media::Video::Editing::Crop instance
        #
        # ### Arguments
        #
        # * *inputs*: hash with the input paths per video format
        # * *output_without_extension*: output path without the extension
        # * *start*: start crop point (in seconds)
        # * *duration*: duration of the cropped file (in seconds)
        # * *log_folder* _optional_: log folder path
        #
        # ### Examples
        #
        #  Media::Video::Editing::Crop.new({ mp4: '/path/to/media.mp4', webm: '/path/to/media.webm' }, '/path/to/cropped/files', 13, 20)
        def initialize(inputs, output_without_extension, start, duration, log_folder = nil)
          unless inputs.is_a?(Hash)                           and 
                 inputs.keys.sort == self.class::FORMATS.sort and
                 inputs.values.all?{ |v| v.is_a? String }
            raise Error.new("inputs must be an Hash with #{self.class::FORMATS.inspect} as keys and strings as values", inputs: inputs)
          end
  
          unless output_without_extension.is_a?(String)
            raise Error.new('output_without_extension must be a String', output_without_extension: output_without_extension)
          end
  
          unless start.is_a?(Numeric) and start >= 0
            raise Error.new('start must be a Numeric >= 0', start: start)
          end
  
          unless duration.is_a?(Numeric) and duration > 0
            raise Error.new('duration must be a Numeric > 0', duration: duration)
          end
  
          @inputs, @output_without_extension, @start, @duration = inputs, output_without_extension, start, duration

          @log_folder = log_folder
        end

        # Execute the crop processing returning the output paths
        def run
          Queue.run *self.class::FORMATS.map{ |format| proc{ crop(format) } }, close_connection_before_execution: true
          outputs
        end
  
        private
        # Format-relative crop processing
        def crop(format)
          create_log_folder
          self.class::CROP_CMD.new(@inputs[format], output(format), @start, @duration, format).run! *logs
        end

        # Format-relative output path
        def output(format)
          "#{@output_without_extension}.#{format}"
        end
  
        # Output paths hash per format
        def outputs
          Hash[ self.class::FORMATS.map{ |format| [format, output(format)] } ]
        end
      end
    end
  end
end

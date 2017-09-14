require 'media'
require 'media/video'
require 'media/video/editing'
require 'media/logging'
require 'media/in_tmp_dir'
require 'media/info'
require 'media/video/editing/cmd/image_to_video'
require 'mini_magick'

module Media
  module Video
    module Editing
      # Convert the supplied image file to videos of the supplied duration
      class ImageToVideo
  
        include Logging
        include InTmpDir
  
        # Processed images output path format
        PROCESSED_IMAGE_PATH_FORMAT = 'processed_image.%s'
  
        # Input path
        attr_reader :input_path
        # Output path without extension
        attr_reader :output_without_extension
        # Output video uration
        attr_reader :duration
  
        # Create a new Media::Video::Editing::ImageToVideo instance
        #
        # ### Arguments
        #
        # * *inputs*: hash with the input paths per video format
        # * *output_without_extension*: output path without the extension
        # * *duration*: duration of the output videos (in seconds)
        # * *log_folder* _optional_: log folder path
        #
        # ### Examples
        #
        #  Media::Video::Editing::ImageToVideo.new({ mp4: '/path/to/media.mp4', webm: '/path/to/media.webm' }, '/path/to/new/video/files', 15)
        def initialize(input_path, output_without_extension, duration, log_folder = nil)
          raise Error.new('duration must be a Numeric > 0', duration: duration) unless duration.is_a? Numeric and duration > 0

          @duration, @input_path, @output_without_extension = duration, input_path, output_without_extension

          @log_folder = log_folder
        end
  
        # Execute the video creation processing
        def run
          in_tmp_dir do
            processed_image_path = tmp_path( PROCESSED_IMAGE_PATH_FORMAT % File.extname(input_path) )
            image_process(processed_image_path)
  
            Queue.run *FORMATS.map{ |format| proc{ convert_to(processed_image_path, format) } }, close_connection_before_execution: true

            mp4_file_info  = Info.new mp4_output_path
            webm_file_info = Info.new webm_output_path
  
            if mp4_file_info.duration != webm_file_info.duration
              raise Error.new( 'output videos have not the same duration',
                               input_path: input_path, processed_image_path: processed_image_path,
                               mp4_output_path: mp4_output_path, webm_output_path: webm_output_path,
                               mp4_duration: mp4_file_info.duration, webm_duration: webm_file_info.duration )
            end
          end
          { webm: webm_output_path, mp4: mp4_output_path }
        end
  
        private
        # Format-relative processing
        def convert_to(processed_image_path, format)
          output_path = output_path(format)
  
          create_log_folder
          stdout_log, stderr_log = stdout_log(format), stderr_log(format)
          cmd        = Cmd::ImageToVideo.new(processed_image_path, output_path, format, duration)
          subexec    = cmd.run %W(#{stdout_log} a), %W(#{stderr_log} a)
          exitstatus = subexec.exitstatus
  
          if exitstatus != 0
            raise Error.new('conversion process failed', format: format, cmd: cmd, exitstatus: exitstatus) 
          end
        end
  
        # MP4 output path
        def mp4_output_path
          output_path(:mp4)
        end
  
        # Webm output path
        def webm_output_path
          output_path(:webm)
        end
  
        # Format-relative output path
        def output_path(format)
          "#{output_without_extension}.#{format}"
        end
  
        # +MiniMagick::Image+ instance of the input image file
        def input
          @input ||= MiniMagick::Image.open(input_path)
        end
  
        # Input image width
        def input_width
          input[:width]
        end
  
        # Input image height
        def input_height
          input[:height]
        end
  
        # Processes the image in order to resize it to the default video sizes
        def image_process(processed_image_path)
          input.combine_options do |cmd|
            cmd.resize  "#{AVCONV_OUTPUT_WIDTH}x#{AVCONV_OUTPUT_HEIGHT}^"
            cmd.gravity 'center'
            cmd.extent  "#{AVCONV_OUTPUT_WIDTH}x#{AVCONV_OUTPUT_HEIGHT}"
          end
          input.write(processed_image_path)
        end
  
      end
    end
  end
end

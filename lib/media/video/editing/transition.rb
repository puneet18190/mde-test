require 'media'
require 'media/video'
require 'media/video/editing'
require 'media/logging'
require 'media/in_tmp_dir'
require 'media/info'
require 'media/video/editing/cmd/video_stream_to_file'
require 'media/video/editing/cmd/extract_frame'
require 'media/video/editing/cmd/generate_transition_frames'
require 'media/video/editing/cmd/transition'
require 'pathname'

module Media
  module Video
    module Editing
      # Creates a video transition between two videos
      class Transition
  
        include Logging
        include InTmpDir
  
        # Start frame image filename
        START_FRAME         = 'start_frame.jpg'
        # Video without the audio filename
        VIDEO_NO_AUDIO      = 'video_no_audio.mp4'
        # Step to be used to seek starting from the end of the +start_inputs+ duration in order to get the last frame (in seconds)
        LAST_FRAME_STEP     = -0.01
        # Duration of the skipping for the last frame seeking (in seconds)
        LAST_FRAME_SKIP     = LAST_FRAME_STEP.abs*3
        # End frame image filename
        END_FRAME           = 'end_frame.jpg'
        # Transition image filename
        TRANSITIONS         = 'transition.jpg'
        # Transition images filename format (<tt>"transition-%d.jpg"</tt>)
        TRANSITIONS_FORMAT  = proc{ f = Pathname.new(TRANSITIONS); "#{f.basename(f.extname)}-%d#{f.extname}" }.call
        # Transition frames amount excluding the first and the last
        INNER_FRAMES_AMOUNT = 23
        # Transition frame rate
        FRAME_RATE          = 25
  
        # Create a new Media::Video::Editing::Transition instance
        #
        # ### Arguments
        #
        # * *start_inputs*: hash with the start video input paths per video format
        # * *end_inputs*: hash with the end video input paths per video format
        # * *output_without_extension*: output path without the extension
        # * *log_folder* _optional_: log folder path
        #
        # ### Examples
        #
        #  Media::Video::Editing::Transition.new({ mp4: '/path/to/start/media.mp4', webm: '/path/to/start/media.webm' }, { mp4: '/path/to/end/media.mp4', webm: '/path/to/end/media.webm' }, '/path/to/new/video/files')
        def initialize(start_inputs, end_inputs, output_without_extension, log_folder = nil)
          unless start_inputs.is_a?(Hash)                       and 
                 start_inputs.keys.sort == FORMATS.sort         and
                 start_inputs.values.all?{ |v| v.is_a? String }
            raise Error.new("start_inputs must be an Hash with #{FORMATS.inspect} as keys and strings as values", start_inputs: start_inputs)
          end
  
          unless end_inputs.is_a?(Hash)                       and
                 end_inputs.keys.sort == FORMATS.sort         and
                 end_inputs.values.all?{ |v| v.is_a? String }
            raise Error.new("end_inputs must be an Hash with #{FORMATS.inspect} as keys and strings as values", end_inputs: end_inputs)
          end
  
          unless output_without_extension.is_a?(String)
            raise Error.new('output_without_extension must be a string', output_without_extension: output_without_extension)
          end
  
          @start_inputs, @end_inputs, @output_without_extension = start_inputs, end_inputs, output_without_extension
          
          @log_folder = log_folder
        end
  
        # Execute the transition creation processing
        #
        # ### Logic
        #
        # 1. Extract the last frame of the start input
        # 2. Extract the last frame of the end input
        # 3. Generate the transition images
        # 4. Generate the video using the transition images
        def run
          create_log_folder
  
          in_tmp_dir do
            start_frame = tmp_path START_FRAME
            extract_start_transition_frame(start_frame) # 1.
  
            end_frame = tmp_path END_FRAME
            extract_end_transition_frame(end_frame) # 2.
  
            transitions = tmp_path TRANSITIONS
            Cmd::GenerateTransitionFrames.new(start_frame, end_frame, transitions, INNER_FRAMES_AMOUNT).run! *logs('3_generate_transition_frames') # 3.
  
            Queue.run *FORMATS.map{ |format| proc{ transition(format) } }, close_connection_before_execution: true # 4.
          end
  
          outputs
        end
  
        private
        # Format-relative processing
        def transition(format)
          create_log_folder
          Cmd::Transition.new(tmp_path(TRANSITIONS_FORMAT), output(format), FRAME_RATE, format).run! *logs("4_#{format}")
        end

        # Extract the start transition frame returning the path, raising an exception if the frame couldn't be extracted
        def extract_start_transition_frame(output_path)
          video_duration = Info.new(@start_inputs[:mp4]).duration
          end_frame_extraction_start_seek(video_duration).step(0, LAST_FRAME_STEP) do |seek|
            Cmd::ExtractFrame.new(@start_inputs[:mp4], output_path, seek).run! *logs('1_extract_start_transition_frame')
            break if File.exists? output_path
          end

          # Raise an exception if couldn't extract the frame
          unless File.exists? output_path
            raise Error.new('start transition frame extraction failed', start_input_mp4: @start_inputs[:mp4])
          end
        end
  
        # Extract the end transition frame returning the path, raising an exception if the frame couldn't be extracted
        def extract_end_transition_frame(output_path)
          Cmd::ExtractFrame.new(@end_inputs[:mp4], output_path, 0).run! *logs('2_extract_end_transition_frame') # 2.
          
          # Raise an exception if couldn't extract the frame
          unless File.exists? output_path
            raise Error.new('end transition frame extraction failed', end_input_mp4: @end_inputs[:mp4])
          end
        end

        # Start seek of the end frame extraction, related to the video duration
        def end_frame_extraction_start_seek(duration)
          duration-LAST_FRAME_SKIP
        end
  
        # Format-relative output path
        def output(format)
          "#{@output_without_extension}.#{format}"
        end
  
        # Output paths hash per format
        def outputs
          Hash[ FORMATS.map{ |format| [format, output(format)] } ]
        end
  
      end
    end
  end
end

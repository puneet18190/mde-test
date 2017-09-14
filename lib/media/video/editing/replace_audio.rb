require 'media'
require 'media/video'
require 'media/video/editing'
require 'media/logging'
require 'media/in_tmp_dir'
require 'media/info'
require 'media/video/editing/cmd/video_stream_to_file'
require 'media/video/editing/cmd/replace_audio'

module Media
  module Video
    module Editing
      # Replace the audio of a video file
      class ReplaceAudio
        
        include Logging
        include InTmpDir
  
        # Audio formats per video format
        CORRESPONDING_AUDIO_FORMATS = { mp4: :m4a, webm: :ogg }
  
        # Create a new Media::Video::Editing::ReplaceAudio instance
        #
        # ### Arguments
        #
        # * *video_inputs*: hash with the input paths per video format
        # * *audio_inputs*: hash with the audio paths which will replace the original audios per video format
        # * *output_without_extension*: output path without the extension
        # * *log_folder* _optional_: log folder path
        #
        # ### Examples
        #
        #  Media::Video::Editing::ImageToVideo.new({ mp4: '/path/to/media.mp4', webm: '/path/to/media.webm' }, { m4a: '/path/to/media.m4a', ogg: '/path/to/media.ogg' }, '/path/to/new/video/files')
        def initialize(video_inputs, audio_inputs, output_without_extension, log_folder = nil)
          unless video_inputs.is_a?(Hash)                       and 
                 video_inputs.keys.sort == FORMATS.sort         and
                 video_inputs.values.all?{ |v| v.is_a? String }
            raise Error.new("video_inputs must be an Hash with #{FORMATS.inspect} as keys and strings as values", video_inputs: video_inputs)
          end
  
          unless audio_inputs.is_a?(Hash)                                          and
                 audio_inputs.keys.sort == CORRESPONDING_AUDIO_FORMATS.values.sort and
                 audio_inputs.values.all?{ |v| v.is_a? String }
            raise Error.new("audio_inputs must be an Hash with #{CORRESPONDING_AUDIO_FORMATS.values.inspect} as keys and strings as values", audio_inputs: audio_inputs)
          end
  
          unless output_without_extension.is_a?(String)
            raise Error.new('output_without_extension must be a string', output_without_extension: output_without_extension)
          end
  
          @video_inputs, @audio_inputs, @output_without_extension = video_inputs, audio_inputs, output_without_extension

          @log_folder = log_folder
        end
  
        # Execute the video creation processing
        def run
          create_log_folder
          in_tmp_dir { Queue.run *FORMATS.map { |format| proc { replace_audio(format) } }, close_connection_before_execution: true }
          outputs
        end
  
        private
        # Format-relative processing
        def replace_audio(format)
          video_input, audio_input = @video_inputs[format], @audio_inputs[ CORRESPONDING_AUDIO_FORMATS[format] ]
          Cmd::ReplaceAudio.new(video_input, audio_input, video_stream_duration(video_input), output(format), format).run! *logs("1_#{format}")
        end
  
        # Extracts the video tracks from +video_input+ and returns its duration
        def video_stream_duration(video_input)
          video_input_info = Info.new video_input
  
          video_input_no_audio_duration =
            if video_input_info.audio_streams.blank?
              video_input_info.duration
            else
              video_input_no_audio = tmp_path "video_no_audio.#{File.extname video_input}"
              Cmd::VideoStreamToFile.new(video_input, video_input_no_audio).run! *logs('0_video_stream_to_file')
              Info.new(video_input_no_audio).duration
            end
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

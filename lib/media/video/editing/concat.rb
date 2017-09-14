require 'media'
require 'media/video'
require 'media/video/editing'
require 'media/logging'
require 'media/in_tmp_dir'
require 'media/info'
require 'media/video/editing/cmd/audio_stream_to_file'
require 'media/video/editing/cmd/m4a_to_wav'
require 'media/audio/editing/cmd/concat'
require 'media/video/editing/cmd/merge_webm_video_streams'
require 'media/video/editing/cmd/concat'

module Media
  module Video
    module Editing
      # Concatenate an array of video files producing a new video as output
      class Concat
  
        include Logging
        include InTmpDir
  
        # Filename of a m4a format concatenation intermediate instance
        CONCAT_M4A_FORMAT      = 'concat%i.m4a'
        # Filename of a wav format concatenation intermediate instance
        CONCAT_WAV_FORMAT      = 'concat%i.wav'
        # Filename of the intermediate wav file
        FINAL_WAV              = 'final.wav'
        # Filename of the intermediate webm file without the audio track
        FINAL_WEBM_NO_AUDIO    = 'final_webm_no_audio.webm'
        # Filename of the output video (mp4 format)
        OUTPUT_MP4_FORMAT      = '%s.mp4'
        # Filename of the output video (webm format)
        OUTPUT_WEBM_FORMAT     = '%s.webm'
        
        # Creates a new Media::Video::Editing::Concat instance, which can be used to concatenate various video files.
        #
        # ### Arguments
        #
        # * *inputs*: an array with hash values containing the video files per format
        # * *output_without_extension*: output path without extension
        # * *log_folder* _optional_: Custom log folder path
        # 
        # See {Examples}[rdoc-label:method-c-new-label-Examples] for usage examples.
        #
        # ### Examples
        #
        #  Media::Video::Editing::Concat.new([ { webm: 'input.webm', mp4: 'input.mp4'}, { webm: 'input2.webm', mp4: 'input2.mp4'} ], '/output/without/extension').run 
        #  #=> { mp4:'/output/without/extension.mp4', webm:'/output/without/extension.webm' }
        #
        def initialize(inputs, output_without_extension, log_folder = nil)
          unless inputs.is_a?(Array) &&
                 inputs.present?     &&
                 inputs.all? do |input|
                   input.is_a?(Hash)                 &&
                   input.keys.sort == FORMATS.sort   &&
                   input.values.size == FORMATS.size &&
                   input.values.all?{ |v| v.is_a?(String) }
                 end
            raise Error.new( "inputs must be an array with at least one element and its elements must be hashes with #{FORMATS.inspect} as keys and strings as values", 
                             inputs: inputs, output_without_extension: output_without_extension )
          end
  
          unless output_without_extension.is_a?(String)
            raise Error.new('output_without_extension must be a string', output_without_extension: output_without_extension)
          end
  
          @inputs, @output_without_extension = inputs, output_without_extension
          
          if mp4_inputs.size != webm_inputs.size
            raise Error.new('mp4_inputs and webm_inputs must be of the same size', inputs: @inputs, output_without_extension: @output_without_extension)
          end

          @log_folder = log_folder
        end
  
        # Runs the concatenation processing
        def run
          # In order to check how many video pairs we have we can check mp4_inputs, because we already checked that mp4_inputs.size == webm_inputs.size inside the initialization
          # Edge case: if there is just one inputs hash we can just copy the inputs to their respective outputs
          return copy_first_inputs_to_outputs if mp4_inputs.size == 1
  
          mp4_inputs_infos = mp4_inputs.map{ |input| Info.new(input) }
          paddings = paddings mp4_inputs_infos
          final_videos = nil
  
          in_tmp_dir { final_videos = concat(mp4_inputs_infos, paddings) }
  
          final_videos
        end
  
        private
        # Edge case management: when there is just one inputs hash we just copy the inputs to their respective outputs
        def copy_first_inputs_to_outputs
          Hash[
            @inputs.first.map do |format, input|
              output = outputs[format]
              FileUtils.cp input, output
              [format, output]
            end
          ]
        end
  
        # Concatenation core processing
        #
        # ### Logic
        #
        # 1. If there is at least one audio streamse c'è almeno uno stream audio:
        #    a. we generate its wav file
        #    b. otherwise we don't
        # 2. We generate the video track concatenating the webm video tracks and discarding their audio tracks; after this operation we have the final audio track in wav format and the final video track in web format
        # 3. We generate the mp4 and the webm videos joining and converting the two tracks
        #
        # ### Arguments
        #
        # * *mp4_inputs_infos*: Media::Info instances about the mp4 input files
        # * *paddings*: an array with the paddings which should be between an audio track and another
        def concat(mp4_inputs_infos, paddings)
          create_log_folder
  
          final_wav = 
            if mp4_inputs_infos.any?{ |info| info.audio_streams.present? } # 1.
              final_wav(mp4_inputs_infos, paddings) # 1.a
            else
              nil # 1.b
            end
  
          final_webm_no_audio = tmp_path FINAL_WEBM_NO_AUDIO
          Cmd::MergeWebmVideoStreams.new(webm_inputs, final_webm_no_audio).run! *logs('3_merge_webm_video_streams') # 2.
  
          final_webm_no_audio_info = Info.new final_webm_no_audio

          Queue.run *FORMATS.map { |format|
            proc {
              Cmd::Concat.new(final_webm_no_audio, final_wav, final_webm_no_audio_info.duration, outputs[format], format).run! *logs("4_#{format}") # 3.
            }
          }, close_connection_before_execution: true
  
          outputs
        end
  
        # Final wav track file generation
        #
        # ### Logic
        #
        # 1. Extracting the m4a from the mp4
        # 2. Converting them to wav (cut-join operations are more precise using lossless formats)
        # 3. Increasing the audio right padding when the wav track is considerably shorter than the respective video track
        # 4. Associating the wavs to the respective paddings
        # 5. Concatenating the wavs adding the paddings
        #
        # \1., 2., 3., 4. steps are executed by the Media::Video::Editing::Concat#wavs_with_paddings method
        def final_wav(mp4_inputs_infos, paddings)
          wavs_with_paddings = wavs_with_paddings(mp4_inputs_infos, paddings)
          final_wav = tmp_path FINAL_WAV
          Audio::Editing::Cmd::Concat.new(wavs_with_paddings, final_wav).run! *logs('2_concat_with_paddings') # 5.
          final_wav
        end

        # Responsible of the 1., 2., 3., 4. steps of the Media::Video::Editing::Concat#final_wav logic (step 3. is delegated to Media::Video::Editing::Concat#increase_rpadding_depending_on_video_overflow )
        def wavs_with_paddings(mp4_inputs_infos, paddings)
          Hash[ {}.tap do |unordered_wavs_with_paddings|
            Queue.run *mp4_inputs_infos.select{ |info| info.audio_streams.present? }.each_with_index.map { |video_info, i|
              proc {
                m4a = tmp_path(CONCAT_M4A_FORMAT % i)
          
                Cmd::AudioStreamToFile.new(video_info.path, m4a).run! *logs("0_audio_stream_to_file_#{i}") # 1.
          
                wav = tmp_path(CONCAT_WAV_FORMAT % i)
                Cmd::M4aToWav.new(m4a, wav).run! *logs("1_m4a_to_wav_#{i}") # 2.
                
                # Increase of right padding when the wav track is considerably shorter than the respective video track, considering that the encoding operation can add a padding by itself
                increase_rpadding_depending_on_video_overflow video_info, wav, paddings[i] # 3.
          
                unordered_wavs_with_paddings[i] = wav, paddings[i] # 4.
              }
            }
          end.sort.map{ |_, wavs_with_paddings| wavs_with_paddings } ]
        end
  
        # Responsible of the step 3. of the Media::Video::Editing::Concat#final_wav logic
        def increase_rpadding_depending_on_video_overflow(video_info, wav, paddings)
          wav_info = Info.new(wav)
          overflow = video_info.duration - wav_info.duration
          paddings[1] += overflow if overflow > 0
        end
  
        # Calculates the audio tracks paddings in order to have as result an audio track whose duration equals the sum of the video durations and synchronized with them. Example:
        # 
        #                         VIDEO
        # 
        #  |----|-----|----|---|----|------|------|----|-----|   VIDEO TRACKS
        #       |-a0--|    |a1-|-a2-|             |-a3-|         AUDIO TRACKS
        #    p0         p1    p2=0         p3             p4       PADDINGS
        # 
        #               a0      a1        a2      a3
        #     ->   [ [p0,p1], [0,p2=0], [0,p3], [0,p4] ]           RESULT
        # 
        def paddings(infos)
          paddings, lpadding = [], 0
  
          infos.each do |info|
            if info.audio_streams.blank?
              if paddings.blank?
                lpadding         += info.duration
              else
                paddings.last[1] += info.duration
              end
              next
            end
  
            paddings << [lpadding, 0]
            lpadding = 0
          end

          paddings
        end
  
        # array of mp4 inputs
        def mp4_inputs
          @mp4_inputs ||= @inputs.map{ |input| input[:mp4] }
        end
  
        # array of the webm inputs
        def webm_inputs
          @webm_inputs ||= @inputs.map{ |input| input[:webm] }
        end
  
        # mp4 output filename
        def mp4_output
          OUTPUT_MP4_FORMAT % @output_without_extension
        end
  
        # webm output filename
        def webm_output
          OUTPUT_WEBM_FORMAT % @output_without_extension
        end
  
        # outputs per format
        def outputs
          { mp4: mp4_output, webm: webm_output }
        end
  
      end
    end
  end
end

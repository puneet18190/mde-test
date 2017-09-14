require 'media'
require 'media/video'
require 'media/video/editing'
require 'media/video/editing/cmd'
require 'media/video/editing/cmd/concat'
require 'media/video/editing/cmd/avconv'
require 'shellwords'

module Media
  module Video
    module Editing
      class Cmd
        class Concat
          # CLI for Media::Video::Editing::Concat processings, webm format - see Media::Video::Editing::Cmd::Concat
          class Webm < Cmd::Avconv
            def initialize(video_input, audio_input, _duration, output)
              @video_input, @audio_input, @duration, @output = video_input, audio_input, _duration, output
              inputs = [@video_input]
              inputs << @audio_input if @audio_input
              super inputs, @output, :webm
              output_options [ vcodec, acodec, duration, shortest ]
            end
  
            private
            # output duration
            def duration
              "-t #{@duration.round(2).to_s.shellescape}"
            end
  
            # video codec
            def vcodec
              '-c:v copy'
            end
  
            # audio codec
            def acodec
              super if @audio_input
            end
  
            # cuts the outputs to the shortest stream duration
            def shortest
              '-shortest'
            end
          end
  
        end
      end
    end
  end
end

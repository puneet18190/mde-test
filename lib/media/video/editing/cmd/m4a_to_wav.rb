require 'media'
require 'media/video'
require 'media/video/editing'
require 'media/video/editing/cmd'
require 'shellwords'

module Media
  module Video
    module Editing
      class Cmd
        # CLI for converting a m4a file to wav
        class M4aToWav < Avconv

          self.output_qa = nil
  
          def initialize(input_file, output_file)
            super([input_file], output_file, nil)

            output_options [ acodec, amap ]
          end

          # Discarding subtitles (not set, unuseful)
          def sn
          end

          # Video quality (not set, unuseful)
          def qv
          end

          # Audio map
          def amap
            '-map 0:a:0'
          end

          # Audio codec
          def acodec
            '-c:a pcm_s16le'
          end

          # Output threads amount
          def output_threads
            '-threads auto'
          end
  
        end
      end
    end
  end
end

require 'media'
require 'media/video'
require 'media/video/editing'
require 'media/video/editing/cmd'
require 'media/cmd/avconv'
require 'shellwords'
require 'subexec'

module Media
  module Video
    module Editing
      class Cmd
        # CLI for video editing using avconv
        class Avconv < Avconv
          self.formats        = FORMATS
          self.codecs         = AVCONV_CODECS
          self.output_threads = AVCONV_OUTPUT_THREADS
          self.output_qa      = AVCONV_OUTPUT_QA
        end
      end
    end
  end
end

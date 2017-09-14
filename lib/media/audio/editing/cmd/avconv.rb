require 'media'
require 'media/audio'
require 'media/audio/editing'
require 'media/audio/editing/cmd'
require 'media/cmd/avconv'
require 'shellwords'
require 'subexec'

module Media
  module Audio
    module Editing
      class Cmd
        # CLI for audio editing using avconv
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

require 'media'
require 'media/audio'
require 'recursive_open_struct'
require 'env_relative_path'

module Media
  module Audio
    
    # Module relative to audio editing
    module Editing
      # +sox+ executable
      SOX_BIN            = CONFIG.sox.cmd.bin
      # +sox+ options (applied on every +sox+ execution)
      SOX_GLOBAL_OPTIONS = CONFIG.sox.cmd.global_options

      # Avconv output codecs per audio format
      AVCONV_CODECS         = Hash[ FORMATS.map{ |f| [f, CONFIG.avtools.avconv.audio.formats.send(f).codecs] } ]
      # Avconv output threads per audio format
      AVCONV_OUTPUT_THREADS = Hash[ FORMATS.map{ |f| [f, CONFIG.avtools.avconv.audio.formats.send(f).threads] } ]
      # Avconv output audio quality per audio format
      AVCONV_OUTPUT_QA      = Hash[ FORMATS.map{ |f| [f, CONFIG.avtools.avconv.audio.formats.send(f).qa] } ]
    end
  end
end

require 'media/audio/editing/concat'
require 'media/audio/editing/crop'
require 'media/audio/editing/conversion'
require 'media/audio/editing/conversion/job'
require 'media/audio/editing/composer'
require 'media/audio/editing/composer/job'
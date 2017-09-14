require 'media'
require 'media/video'
require 'media/video/editing'
require 'shellwords'

module Media
  module Video
    # Module relative to video editing
    module Editing
      
      # +avprobe+ executable
      AVPROBE_BIN = CONFIG.avtools.avprobe.cmd.bin
  
      # +avconv+ codecs 
      AVCONV_CODECS            = Hash[ FORMATS.map{ |f| [f, CONFIG.avtools.avconv.video.formats.send(f).codecs] } ]
      # +avconv+ default bitrates
      AVCONV_DEFAULT_BITRATES  = Hash[ FORMATS.map{ |f| [f, CONFIG.avtools.avconv.video.formats.send(f).default_bitrates] } ]
  
      # +avconv+ output width
      AVCONV_OUTPUT_WIDTH        = CONFIG.avtools.avconv.video.output.width
      # +avconv+ output height
      AVCONV_OUTPUT_HEIGHT       = CONFIG.avtools.avconv.video.output.height
      # +avconv+ output aspect ratio
      AVCONV_OUTPUT_ASPECT_RATIO = Rational(AVCONV_OUTPUT_WIDTH, AVCONV_OUTPUT_HEIGHT)
      # +avconv+ output encoding threads (per codec)
      AVCONV_OUTPUT_THREADS      = Hash[ FORMATS.map{ |f| [f, CONFIG.avtools.avconv.video.formats.send(f).threads] } ]
      # +avconv+ output audio quality (per codec)
      AVCONV_OUTPUT_QA           = Hash[ FORMATS.map{ |f| [f, CONFIG.avtools.avconv.video.formats.send(f).qa] } ]
  
      # ImageMagick +convert+ executable
      IMAGEMAGICK_CONVERT_BIN = CONFIG.imagemagick.convert.cmd.bin
  
    end
  end
end

require 'media/video/editing/image_to_video'
require 'media/video/editing/text_to_video'
require 'media/video/editing/concat'
require 'media/video/editing/crop'
require 'media/video/editing/replace_audio'
require 'media/video/editing/transition'
require 'media/video/editing/conversion'
require 'media/video/editing/conversion/job'
require 'media/video/editing/composer'
require 'media/video/editing/composer/job'

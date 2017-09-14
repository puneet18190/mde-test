require 'media'

module Media
  # Module related to the audios processing
  module Audio
    # Supported output formats
    FORMATS         = CONFIG.avtools.avconv.audio.formats.marshal_dump.keys
    # Supported output versions
    VERSION_FORMATS = {}
  end
end

require 'media/audio/uploader'
require 'media/audio/editing'
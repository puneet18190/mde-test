require 'media'

module Media
  # Module related to the video management
  module Video
    # Supported output formats
    FORMATS                    = CONFIG.avtools.avconv.video.formats.marshal_dump.keys
    # Supported output versions
    VERSION_FORMATS            = { cover: CONFIG.video.cover_format, thumb: CONFIG.video.thumb_format }
    # Cover and thumb version formats
    COVER_FORMAT, THUMB_FORMAT = VERSION_FORMATS[:cover], VERSION_FORMATS[:thumb]
    # Thumb version sizes
    THUMB_SIZES                = CONFIG.video.thumb_sizes
  end
end

require 'media/video/uploader'
require 'media/video/editing'
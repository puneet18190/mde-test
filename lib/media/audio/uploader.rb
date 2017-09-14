require 'media'
require 'media/audio'
require 'media/uploader'
require 'media/similar_durations'
require 'media/audio/editing/conversion/job'
require 'env_relative_path'

module Media
  module Audio

    # Video uploading class; descendant of Media::Uploader
    class Uploader < Uploader

      require 'media/audio/uploader/validation'

      include Validation
      include EnvRelativePath

      # Path to audios folder relative to Rails public folder (for web URLs)
      PUBLIC_RELATIVE_FOLDER        = env_relative_path File.join(PUBLIC_RELATIVE_MEDIA_ELEMENTS_FOLDER, 'audios')
      # Absolute path to audios folder
      FOLDER                        = File.join Rails.public_pathname, PUBLIC_RELATIVE_FOLDER
      # Allowed uploaded audio extensions
      EXTENSION_WHITE_LIST          = %w(mp3 ogg oga flac aiff wav wma aac m4a)
      # Allowed uploaded audio extensions with dots
      EXTENSION_WHITE_LIST_WITH_DOT = EXTENSION_WHITE_LIST.map{ |ext| ".#{ext}" }
      # Minimum allowed uploaded audio duration
      MIN_DURATION                  = 1
      # Maximum difference between two generated formats of the same audio
      DURATION_THRESHOLD            = CONFIG.duration_threshold
      # Audio ouput formats
      FORMATS                       = FORMATS
      # Allowed keys when initializing a new Media::Audio::Uploader instance with an hash as value
      ALLOWED_KEYS                  = [:filename] + FORMATS
      # Output versiosn formats (thumb, cover...)
      VERSION_FORMATS               = VERSION_FORMATS
      # Ruby class responsible of the conversion process
      CONVERSION_CLASS              = Editing::Conversion

      private
      # Since audio media don't have versions, it does nothing
      def extract_versions(infos)
      end

    end
  end
end

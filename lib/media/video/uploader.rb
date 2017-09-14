require 'media'
require 'media/video'
require 'media/uploader'
require 'media/similar_durations'
require 'media/video/editing/cmd/extract_frame'
require 'media/video/editing/conversion'
require 'media/video/editing/conversion/job'
require 'media/image/editing/resize_to_fill'
require 'env_relative_path'

module Media
  module Video

    # Video uploading class; descendant of Media::Uploader
    class Uploader < Uploader

      require 'media/video/uploader/validation'

      include Validation
      include EnvRelativePath

      # Path to videos folder relative to Rails public folder (for web URLs)
      PUBLIC_RELATIVE_FOLDER        = env_relative_path File.join(PUBLIC_RELATIVE_MEDIA_ELEMENTS_FOLDER, 'videos')
      # Absolute path to videos folder
      FOLDER                        = File.join Rails.public_pathname, PUBLIC_RELATIVE_FOLDER
      # Allowed uploaded video extensions
      EXTENSION_WHITE_LIST          = %w(avi divx flv h264 mkv mov mp4 mpe mpeg mpg ogm ogv webm wmv xvid)
      # Allowed uploaded video extensions with dots
      EXTENSION_WHITE_LIST_WITH_DOT = EXTENSION_WHITE_LIST.map{ |ext| ".#{ext}" }
      # Minimum allowed uploaded video duration
      MIN_DURATION                  = 1
      # Maximum difference between two generated formats of the same video
      DURATION_THRESHOLD            = CONFIG.duration_threshold
      # Video ouput formats
      FORMATS                       = FORMATS
      # Allowed keys when initializing a new Media::Video::Uploader instance with an hash as value
      ALLOWED_KEYS                  = [:filename] + FORMATS
      # Output versions formats (thumb, cover...)
      VERSION_FORMATS               = VERSION_FORMATS
      # Ruby class responsible of the conversion process
      CONVERSION_CLASS              = Editing::Conversion

      private

      # Generate the additional versions; it copies the files if their input paths have been provided before
      def extract_versions(infos)
        if version_input_paths?
          version_input_paths.each do |version, input|
            FileUtils.cp input, send(:"#{version}_output_path")
          end
        else
          extract_cover @converted_files[:mp4], cover_output_path, infos[:mp4].duration
          extract_thumb cover_output_path, thumb_output_path, *THUMB_SIZES
        end
      end

      # Generate the additional cover versions
      def extract_cover(input, output, duration)
        seek = duration / 2
        Editing::Cmd::ExtractFrame.new(input, output, seek).run!
        raise StandardError, 'unable to create cover' unless File.exists? output
      end

      # Generate the additional thumb versions
      def extract_thumb(input, output, width, height)
        Image::Editing::ResizeToFill.new(input, output, width, height).run
      end

      # Cover file output path
      def cover_output_path
        File.join output_folder, COVER_FORMAT % processed_original_filename_without_extension
      end

      # Thumb file output path
      def thumb_output_path
        File.join output_folder, THUMB_FORMAT % processed_original_filename_without_extension
      end
    end
  end
end

require 'env_relative_path'
require 'find'
require 'media'

class ImageUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick
  include EnvRelativePath

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper

  storage :file

  STORE_DIR            = env_relative_path "media_elements/images"
  FOLDER               = Rails.public_pathname.join(STORE_DIR).to_s
  EXTENSION_WHITE_LIST = %w(jpg jpeg png)

  def self.remove_folder!
    FileUtils.rm_rf FOLDER
  end

  def self.folder_size
    return 0 unless Dir.exists? FOLDER
    Find.find(FOLDER).sum { |f| File.stat(f).size }
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    File.join STORE_DIR, "#{model.id}"
  end

  def cache_dir
    Rails.root.join 'tmp/media_elements/images'
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end
  process :resize_to_fit => [1400, 1400]

  version :thumb do
    process :resize_to_fill => [200, 200]
  end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    EXTENSION_WHITE_LIST
  end

  def image
    @image ||= MiniMagick::Image.open(path)
  end

  def width
    image[:width]
  end

  def height
    image[:height]
  end

  def folder
    File.dirname path if path
  end

  def original_extension
    File.extname(original_filename) if original_filename
  end

  def original_filename_without_extension
    File.basename(original_filename, original_extension) if original_filename
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    "#{original_filename_without_extension.parameterize}_#{model.filename_token}#{original_extension}" if original_filename
  end

  def paths
    { main: file.path, thumb: thumb.file.path }
  end

end

require 'fileutils'
require 'pathname'
require 'set'

class Slide::MathImages < Set

  CACHE_FOLDER = Rails.root.join 'vendor', 'assets', 'javascripts', 'tinymce', 'plugins', 'tiny_mce_wiris', 'cache'
  FOLDER       = Rails.root.join 'app', 'exports', 'lessons', 'math_images'
  CSS_SELECTOR = 'img.Wirisformula'

  attr_accessor :model_id

  def initialize(filenames = [], model_id = nil)
    super filenames.map{ |v| Pathname.new(v).basename }
    @model_id = model_id
  end

  def valid?
    _folders_images = model_id ? folders_images : cache_folder_images
    all?{ |v| _folders_images.include?(v) }
  end

  def invalid?
    !valid?
  end

  def save
    return true if blank?
    
    folder.mkpath

    _folder_images = folder_images

    # Cancello le immagini vecchie
    _folder_images.each do |v|
      next if include? v
      v.unlink
    end

    # Metto quelle nuove
    each do |v|
      next if _folder_images.include? v
      FileUtils.cp CACHE_FOLDER.join(v), folder
    end

  end

  def copy_to(copy_model_id)
    copy_folder = folder copy_model_id
    remove_folder copy_folder
    FileUtils.cp_r folder, copy_folder if folder.exist?

    copy = dup
    copy.model_id = copy_model_id
    copy
  end

  def to_a(modality = nil)
    case modality
    when :full_path
      _folder = folder
      super().map{ |v| _folder.join(v) }
    else
      super()
    end
  end

  def remove_folder(_folder = folder)
    _folder.rmtree if _folder.exist?
  end

  # private

  def folder(id = model_id)
    raise "couldn't determine the folder without id" unless id
    FOLDER.join id.to_s
  end

  def folders_images
    Set.new (folder_images + cache_folder_images)
  end

  def cache_folder_images
    Pathname.glob(CACHE_FOLDER.join '*.png').map{ |v| v.basename }
  end

  def folder_images
    Pathname.glob(folder.join '*.png').map{ |v| v.basename }
  end

end

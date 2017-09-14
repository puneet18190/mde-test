require 'shellwords'
require 'media/image/editing'
require 'media/image/editing/add_text_to_image'
require 'media/image/editing/crop'

# ### Description
#
# This class inherits from MediaElement, and contains the specific methods needed for media elements of type +image+.
# 
class Image < MediaElement
  
  include UrlTypes

  # List of accepted extensions for an image
  EXTENSION_WHITE_LIST = ImageUploader::EXTENSION_WHITE_LIST

  # Glob for find images using <tt>Dir.glob</tt>
  EXTENSIONS_GLOB = "*.{#{EXTENSION_WHITE_LIST.join(',')}}"

  EBOOK_FORMATS = [nil]
  
  mount_uploader :media, ImageUploader
  
  before_save :set_width_and_height
  before_create :set_converted_to_true
  
  attr_reader :edit_mode
  
  # Container size
  CONTAINER_SIZE_BY_KIND = { Slide::COVER              => [900, 560] ,
                             Slide::IMAGE1             => [420, 420] ,
                             Slide::IMAGE2             => [420, 550] ,
                             Slide::IMAGE3             => [860, 550] ,
                             Slide::IMAGE4             => [420, 265] ,
                             'video_component'         => [156, 88 ] ,
                             'video_component_preview' => [640, 360] }

  CONTAINER_WIDTHS_BY_KIND  = Hash[ CONTAINER_SIZE_BY_KIND.map{ |k, (w, _)| [ k, w ] } ]
  CONTAINER_HEIGHTS_BY_KIND = Hash[ CONTAINER_SIZE_BY_KIND.map{ |k, (_, h)| [ k, h ] } ]
  CONTAINER_RATIOS_BY_KIND  = Hash[ CONTAINER_SIZE_BY_KIND.map{ |k, (w, h)| [ k, Rational(w, h) ] } ]

  # ### Description
  #
  # Elaborates the CSS background-position property in order to 
  # position the image when used as background of a HTML element.
  # The returned property is in percentage so it can be used regardless
  # of the container size.
  #
  # Calcolo background-position immagine orizzontale e spalmata
  #
  #   o    offset dell'immagine
  #   hc   altezza del contenitore
  #   hi   altezza dell'immagine
  #   s    centro di posizione
  #   x    valore di background-position in percentuale
  #
  #             immagine
  #   ─   ┌──────────────────┐       ─
  #       │                  │     
  #       │                  │     
  #   o   │                  │     
  #       │                  │     
  #       │                  │     
  #       │                  │     
  #       │   contenitore    │     
  #   ─   ┢━━━━━━━━━━━━━━━━━━┪   ─ 
  #       ┃                  ┃     
  #       ┃                  ┃   hc  hi
  #       ┃                  ┃     
  #   s ─ ┃                  ┃     
  #       ┡━━━━━━━━━━━━━━━━━━┩   ─ 
  #       │                  │     
  #       └──────────────────┘       ─
  #
  #   o va da 0 a hi - hc
  #   il centro di posizione va da 0 a hc
  #   dunque x : o = hc : (hi - hc)
  #   x = o * hc / (hi - hc)
  #   adesso mi serve il rapporto di x / hc moltiplicato per 100 per ottenere la percentuale
  #   x / hc * 100 = o * hc * 100 / ((hi - hc) * hc) = o * 100 / (hi - hc)
  #
  #
  # Calcolo background-position immagine verticale e iscritta
  #
  #   o    offset dell'immagine
  #   wc   larghezza del contenitore
  #   wi   larghezza dell'immagine iscritta
  #   s    centro di posizione
  #   x    valore di background-position in percentuale
  #
  #
  #       │                wc                  │
  #
  #                   │  wi   │
  #
  #       ┌───────────┲━━━━━━━┱────────────────┐
  #       │           ┃       ┃                │
  #       │           ┃       ┃                │
  #       │           ┃       ┃ immagine       │ contenitore
  #       │           ┃       ┃                │
  #       │           ┃       ┃                │
  #       │           ┃       ┃                │
  #       └───────────┺━━━━━━━┹────────────────┘
  #                      │
  #       │     o     │  s
  #
  #   o va da 0 a wc - wi
  #   il centro di posizione va da 0 a wc
  #   dunque x : o = wc : (wc - wi)
  #   x = o * wc / (wc - wi)
  #   adesso mi serve il rapporto di x / wc moltiplicato per 100 per ottenere la percentuale
  #   x / wc * 100 = o * wc * 100 / ((wc - wi) * wc) = o * 100 / (wc - wi)
  #
  # ### Returns
  #
  # A value compliant to background-position
  #
  def background_position(kind, alignment)
    w_h    = ['0', '0']
    offset = alignment.abs

    return w_h.join(' ') if offset == 0

    resize, i      = is_horizontal?(kind) ? [resize_width(kind), 0] : [resize_height(kind), 1]
    container_size = CONTAINER_SIZE_BY_KIND[kind][i]
    difference     = resize > container_size ? resize - container_size : container_size - resize

    v      = (offset * 100.0 / difference).round 5
    w_h[i] = "#{v}%"

    w_h.join(' ')
  end
  
  # Used to give an orientation on images
  def is_horizontal?(kind)
    ( width.to_f / height.to_f ) >= CONTAINER_RATIOS_BY_KIND[kind]
  end
  
  # Resizes the width of an image
  def resize_width(kind)
    ( width.to_f  * CONTAINER_HEIGHTS_BY_KIND[kind] / height ).to_i + 1
  end
  
  # Resizes the height of an image
  def resize_height(kind)
    ( height.to_f * CONTAINER_WIDTHS_BY_KIND[kind] / width ).to_i + 1
  end
  
  # ### Description
  #
  # Returns the url of the attached image.
  #
  # ### Returns
  #
  # An url
  #
  # ### Usage
  #
  #   <%= image_tag image.url %>
  #
  def url(url_type = nil)
    url = media.url

    url_by_url_type url, url_type
  end
  
  # ### Description
  #
  # Returns the url of the 200x200 thumb of the attached image.
  #
  # ### Returns
  #
  # An url
  #
  # ### Usage
  #
  #   <%= image_tag image.thumb_url %>
  #
  def thumb_url
    media.thumb.url
  end
  
  # ### Description
  #
  # Returns the width in pixels.
  #
  # ### Returns
  #
  # A float.
  #
  def width
    metadata.width
  end
  
  # ### Description
  #
  # Returns the height in pixels.
  #
  # ### Returns
  #
  # A float.
  #
  def height
    metadata.height
  end
  
  # ### Description
  #
  # Returns the url of the folder where it's conserved the temporary image during editing.
  #
  # ### Returns
  # An url.
  #
  def editing_url
    return '' if !self.in_edit_mode?
    file_name = "/#{url.split('/').last}"
    "#{url.gsub(file_name, '')}/editing/user_#{@edit_mode}/tmp.#{self.media.file.extension}"
  end
  
  # ### Description
  #
  # Returns the path of the previous step conserved in image editor: this replaces the current step if the user clicks on 'undo'
  #
  # ### Returns
  #
  # A path.
  #
  def prev_editing_image
    return '' if !self.in_edit_mode?
    "#{self.media.folder}/editing/user_#{@edit_mode}/prev.#{self.media.file.extension}"
  end
  
  # ### Description
  #
  # Returns the path of the current step conserved in image editor.
  #
  # ### Returns
  #
  # A path.
  #
  def current_editing_image
    return '' if !self.in_edit_mode?
    "#{self.media.folder}/editing/user_#{@edit_mode}/tmp.#{self.media.file.extension}"
  end
  
  # ### Description
  #
  # Used to check if the image is in *edit* *mode*: the image enters in edit mode when the image editor is opened, this implies that a temporary folder is automaticly created to contain the progressive steps of the editing. This method is useful to deny the access to specific methods if the image is not in editing.
  #
  # ### Returns
  #
  # A boolean.
  #
  # ### Usage
  #
  #   return '' if !self.in_edit_mode?
  #
  def in_edit_mode?
    !@edit_mode.nil?
  end
  
  # ### Description
  #
  # The image enters in *edit* *mode* for a particular user (who is not necessarily the creator of the image, this is checked in the controller). Used in ImageEditorController.
  #
  # ### Arguments
  #
  # * *user_id*: id of the user who is editing the image
  #
  def enter_edit_mode(user_id)
    @edit_mode = user_id
    ed_dir = "#{self.media.folder}/editing/user_#{@edit_mode}"
    FileUtils.mkdir_p(ed_dir) if !Dir.exists?(ed_dir)
    curr_path = current_editing_image
    FileUtils.cp(self.media.path, curr_path) if !File.exists?(curr_path)
    true
  end
  
  # ### Description
  #
  # The image leaves the *edit* *mode* for a particular user. Used in ImageEditorController#edit.
  #
  # ### Arguments
  #
  # * *user_id*: id of the user who is editing the image
  #
  # ### Returns
  #
  # True if the user was in editing mode, false otherwise.
  #
  def leave_edit_mode(user_id)
    ed_dir = "#{self.media.folder}/editing/user_#{user_id}"
    begin
      FileUtils.rm_r(ed_dir)
    rescue
      return false
    end
    @edit_mode = nil
    true
  end
  
  # ### Description
  #
  # Copies the current temporary image into the previous temporary image.
  #
  # ### Returns
  #
  # A boolean.
  #
  def save_editing_prev
    return false if !self.in_edit_mode?
    prev_path = self.prev_editing_image
    curr_path = self.current_editing_image
    begin
      FileUtils.rm(prev_path) if File.exists?(prev_path)
      FileUtils.cp(curr_path, prev_path)
    rescue
      return false
    end
    true
  end
  
  # ### Description
  #
  # Copies the previous temporary image into the current temporary image. Used in ImageEditorController#undo.
  #
  # ### Returns
  #
  # A boolean.
  #
  def undo
    return false if !self.in_edit_mode?
    prev_path = self.prev_editing_image
    curr_path = self.current_editing_image
    return false if !File.exists? prev_path
    FileUtils.rm(curr_path)
    FileUtils.cp(prev_path, curr_path)
    FileUtils.rm(prev_path)
    true
  end
  
  # ### Description
  #
  # Adds multiple texts in the temporary image. Used in ImageEditorController#add_text
  #
  # ### Arguments
  #
  # * *texts*: an array of hashes, one for each text added. Each hash has the keys
  #   * +font_size+: the font size
  #   * +coord_x+: horizontal coordinates of the top left corner of the text
  #   * +coord_y+: vertical coordinates of the top left corner of the text
  #   * +color+: hexagonal color of the text
  #
  # ### Returns
  #
  # A boolean.
  #
  def add_text(texts)
    return false if !self.in_edit_mode? || !self.save_editing_prev
    img = MiniMagick::Image.open self.current_editing_image
    texts.each do |t|
      font_size = Media::Image::Editing.ratio_value img[:width], img[:height], t[:font_size]
      coord_x = Media::Image::Editing.ratio_value img[:width], img[:height], t[:coord_x]
      coord_y = Media::Image::Editing.ratio_value img[:width], img[:height], t[:coord_y]
      tmp_file = Tempfile.new(Rails.application.config.tempfiles_prefix.call)
      begin
        tmp_file.write(t[:text])
        tmp_file.close
        Media::Image::Editing::AddTextToImage.new(self.current_editing_image, t[:color], font_size, coord_x, coord_y, tmp_file).run!
      ensure
        tmp_file.unlink
      end
    end
    true
  end
  
  # ### Description
  #
  # Crops the temporary image. Used in ImageEditorController#crop
  #
  # ### Arguments
  #
  # * *x1*: horizontal coordinate of the top left corner of the crop
  # * *y1*: vertical coordinate of the top left corner of the crop
  # * *x2*: horizontal coordinate of the bottom right corner of the crop
  # * *y2*: vertical coordinate of the bottom right corner of the crop
  #
  # ### Returns
  #
  # A boolean.
  #
  def crop(x1, y1, x2, y2)
    return false if !in_edit_mode? || !save_editing_prev
    Media::Image::Editing::Crop.new(current_editing_image, current_editing_image, x1, y1, x2, y2).run
    true
  end

  # Image file extension (without dot)
  def extension
    media.try(:file).try(:extension)
  end

  # Image file size
  def size
    media.try(:size)
  end
  
  private
  
  # Sets the +width+ in +metadata+
  def width=(width)
    metadata.width = width
  end
  
  # Sets the +height+ in +metadata+
  def height=(height)
    metadata.height = height
  end
  
  # Sets +width+ and +height+ according to the data contained in +media+
  def set_width_and_height
    self.width, self.height = media.width, media.height
    true
  end
  
  # Sets +converted+ to true
  def set_converted_to_true
    self.converted = true
    true
  end
  
end

require 'filename_token'
require 'lessons_media_elements_shared'

# ### Description
#
# ActiveRecord class that corresponds to the table +media_elements+; this model has single table inheritance on the field +sti_type+ (see the models Image, Audio and Video). Audios and videos have shared behaviors, defined in Media::Shared.
#
# ### Fields
#
# * *user_id*: reference to the User who created the element
# * *sti_type*: single table iheritance representing the media type
# * *media*: attached audio, video or image
# * *title*: title
# * *description*: description
# * *metadata*: can contain different keys, depending on +sti_type+
#   * *audio*
#     * +creation_mode+: it can be *uploaded* (if the element was originally uploaded), or *composed* (if it was created inside the application using other elements)
#     * +m4a_duration+: the float duration of the m4a attached file
#     * +ogg_duration+: the float duration of the ogg attached file
#   * *image*
#     * +width+: width of the original image
#     * +height+: height of the original image
#   * *video*
#     * +creation_mode+: it can be *uploaded* (if the element was originally uploaded), or *composed* (if it was created inside the application using other elements)
#     * +mp4_duration+: the float duration of the mp4 attached file
#     * +webm_duration+: the float duration of the webm attached file
# * *converted*: always +true+ for Image; for Video and Audio it is +false+ if the media element is not available
# * *is_public*: if +true+, the element is contained in the public database of the application
# * *publication_date*: if +is_public+ is +true+, this is the date in which the element has been published (once it's published it can't be turned back into private)
#
# ### Associations
#
# * *bookmarks*: links created by other users to this element (see Bookmark) (*has_many*)
# * *media_elements_slides*: all the instances of this element (see MediaElementsSlide) (*has_many*)
# * *reports*: reports on the element (see Report) (*has_many*)
# * *taggings*: tags associated to the element (see Tagging, Tag) (*has_many*)
# * *taggings_tags*: link to the objects of type Tag, through the association +taggings+ (*has_many*)
# * *user*: the User who created the element (*belongs_to*)
#
# ### Validations
#
# * *presence* with numericality > 0 and presence of associated object for +user_id+
# * *presence* of +title+ and +description+
# * *inclusion* of +is_public+ in [+true+, +false+]
# * *inclusion* of +sti_type+ in ['+Audio+', '+Image+', '+Video+'] (these three values correspond to an *enum* defined in postgresql)
# * *length* of +title+ (maximum configured in the translation file; if the value is greater than 255 it's set to 255)
# * *length* of +description+ (maximum configured in the translation file)
# * *presence* of +media+; <b>this validation is skipped if the element is of type Video or Audio, and if the element is being composed</b>: in fact, in this case there is not yet a media to be attached (unlike when the element is uploaded, because when it's uploaded there exists a media file but it's not yet converted)
# * *if* *the* *element* *is* *public*, +publication_date+ can't be null, whereas if it's private it must be null
# * *the* *element* *cannot* *be* *public* if new record. <b>This validation is not fired if skip_public_validations is +true+</b>
# * *if* *the* *element* *is* *public*, the fields +media+, +title+, +description+, +is_public+, +publication_date+ can't be changed anymore. <b>This validation is not fired if skip_public_validations is +true+</b>
# * *if* *the* *element* *is* *private*, the field +user_id+ can't be changed (this field may be changed only if the element is public, because if the user decides to close his profile, the public elements that he created can't be deleted: using User#destroy_with_dependencies they are switched to another owner (the super administrator of the application, see User.admin)
# * *minimum* *number* of tags (configurated in config/settings.yml), <b>only if the attribute save_tags is set as +true+</b>
# * *size* of the file attached to +media+ (configured in settings.yml, in megabytes)
# * *specific* *media* *validation* depending on the type of attached media (see Media::Video::Uploader::Validation, Media::Audio::Uploader::Validation, ImageUploader, this last being carried out automatically by CarrierWave)
# * <b>the maximum size of the media elements folder size</b> (configured in config/settings.yml, in gigabytes)
#
# ### Callbacks
#
# * *general* *callbacks*:
#   * *on* *the* *method* *new*, it's called MediaElement.new_with_sti_type_inferring, which infers the type of +media+ and defines the correct class among Image, Audio, Video
#   * *before_destroy*, if +is_public+ == +true+ the destruction is stopped (<b>this callback is not executed if the attribute destroyable_even_if_public is set as +true+</b>: this is necessary to destroy public elements from the administrator, see Admin::MediaElementsController#destroy)
#   * *before_destroy* destroys associated bookmarks (see Bookmark)
#   * *before_destroy* destroys associated reports (see Report)
#   * *before_destroy* destroys associated taggings (see Tagging)
#   * *after_save* updates taggings associated to the media element (see Tagging). If a Tag doesn't exist yet, it is created too. The tags are stored before the validation in the private attribute +inner_tags+. Notice that <b>this callback must be declared before calling +require+ for the submodels</b>, because the +after_save+ of tags must be called before the +after_save+ of the uploader (see private validation methods in Media::Shared, and callbacks in Image)
# * *callbacks* *only* *for* Image type:
#   * *before_save* sets +width+ and +height+ according to the attached image
#   * *before_create* sets +converted+ to true, since during the uploading of an Image we don't have to wait for conversion, as happens in Video and Audio
# * *callbacks* *only* *for* Audio and Video types:
#   * *before_create* sets the +creation_mode* (+uploaded+ if the element was originally uploaded, or +composed+ if it was created inside the application)
#   * *after_save* calls +upload_or_copy+ in Media::Shared
#   * *before_destroy* stops the destruction if +converted+ == +false+ (<b>this callback doesn't execute if the attribute destroyable_even_if_not_converted in Media::Shared is set to +true+</b>: this is necessary if something goes wrong with the creation of a new media element, in this case the not converted element must be deleted)
#   * *after_destroy* cleans the folder containing the attached files (mp4, m4a, webm, ogg)
#
# ### Database callbacks
#
# * *cascade* *destruction* for the associated table MediaElementsSlide
#
# ### Other details
#
# It's defined a scope *of* that filters automaticly all the elements of a user (see User#own_media_elements):
#   SELECT "media_elements".* FROM "media_elements" LEFT JOIN bookmarks ON bookmarks.bookmarkable_id = media_elements.id
#   AND bookmarks.bookmarkable_type = 'MediaElement' AND bookmarks.user_id = 1 WHERE (bookmarks.user_id IS NOT NULL
#   OR (media_elements.is_public = false AND media_elements.user_id = 1)) ORDER BY COALESCE(bookmarks.created_at, media_elements.updated_at) DESC
#
class MediaElement < ActiveRecord::Base
  include FilenameToken
  extend LessonsMediaElementsShared
  
  self.inheritance_column = :sti_type
  
  after_save :update_or_create_tags
  
  IMAGE_TYPE, AUDIO_TYPE, VIDEO_TYPE = %W(Image Audio Video)
  
  # List of possible values for the field +sti_type+ (they correspond to an enum defined in postgresql)
  STI_TYPES = [IMAGE_TYPE, AUDIO_TYPE, VIDEO_TYPE]
  
  # List of available display modes in the section 'elements'
  DISPLAY_MODES = { compact: 'compact', expanded: 'expanded' }
  
  # Maximum media size expressed in megabytes
  MAX_MEDIA_SIZE = SETTINGS['max_media_size'].megabytes
  
  # Maximum length of the title, configured in the translation file and limited by 255 if it's higher
  MAX_TITLE_LENGTH = (I18n.t('language_parameters.media_element.length_title') > 255 ? 255 : I18n.t('language_parameters.media_element.length_title'))
  
  serialize :metadata, OpenStruct
    
  # True if in the front end the element contains the icon to send a report
  attr_reader :is_reportable
  # True if in the front end the element contains the icon to change general information
  attr_reader :info_changeable
  # Set to true if it's necessary to validate the number of tags (typically this happens in the public front end)
  attr_writer :save_tags
  # Set to true when it's necessary to destroy public elements (used in the administrator section, see Admin::MediaElementsController#destroy)
  attr_accessor :destroyable_even_if_public
  # Set to true when it's necessary to skip the public error (used in seeding)
  attr_accessor :skip_public_validations
  
  has_many :bookmarks, :as => :bookmarkable, :dependent => :destroy
  has_many :media_elements_slides
  has_many :reports, :as => :reportable, :dependent => :destroy
  has_many :taggings, :as => :taggable, :dependent => :destroy
  has_many :taggings_tags, :through => :taggings, :source => :tag
  belongs_to :user
  
  validates_presence_of :user_id, :title, :description
  validates_inclusion_of :is_public, :in => [true, false]
  validates_inclusion_of :sti_type, :in => STI_TYPES
  validates_numericality_of :user_id, :only_integer => true, :greater_than => 0
  validates_length_of :title, :maximum => MAX_TITLE_LENGTH
  validates_length_of :description, :maximum => I18n.t('language_parameters.media_element.length_description')
  validates_presence_of :media, :unless => proc{ |record| [Video, Audio].include?(record.class) && record.composing }
  validate :validate_associations, 
           :validate_publication_date, 
           :validate_impossible_changes, 
           :validate_tags_length, 
           :validate_size, 
           :validate_maximum_media_elements_folder_size
  
  before_validation :init_validation
  before_destroy :stop_if_public
  
  scope :of, ->(user_or_user_id) do
    user_id = user_or_user_id.instance_of?(User) ? user_or_user_id.id : user_or_user_id
    joins(sanitize_sql ["LEFT JOIN bookmarks ON 
                         bookmarks.bookmarkable_id = media_elements.id AND
                         bookmarks.bookmarkable_type = 'MediaElement' AND
                         bookmarks.user_id = %i", user_id] ).
    where('bookmarks.user_id IS NOT NULL OR (media_elements.is_public = false AND media_elements.user_id = ?)', user_id).
    order('COALESCE(bookmarks.created_at, media_elements.updated_at) DESC')
  end
  
  class << self
    
    # ### Description
    #
    # Alias for the method +new+, that additionally infers the media type and selects the submodel among Audio, Image and Video
    #
    # ### Args
    #
    # * *attributes*: attributes that eventually can be initialized in the new media element
    # * *options*: additional options
    # * *block*: block to be executed
    #
    # ### Usage
    #
    # See for instance MediaElementsController#create
    #   media = params[:media]
    #   record = MediaElement.new :media => media
    #
    def new_with_sti_type_inferring(attributes = nil, options = {}, &block)
      media = attributes.try :[], :media
      unless media.is_a?(ActionDispatch::Http::UploadedFile) || media.is_a?(File)
        return new_without_sti_type_inferring(attributes, options, &block)
      end
      extension = File.extname(
          case media
          when ActionDispatch::Http::UploadedFile then media.original_filename
          when File                               then media.path
          end
        ).sub(/^\./, '').downcase
      inferred_sti_type = Hash[ [Image, Video, Audio].
        map{ |v| [v, v.const_get(:EXTENSION_WHITE_LIST)] } ].
        detect{ |_,v| v.include? extension }.
        try(:first)
      unless inferred_sti_type
        return new_without_sti_type_inferring(attributes, options, &block)
      end
      inferred_sti_type.new_without_sti_type_inferring(attributes, options, &block)
    end
    alias_method_chain :new, :sti_type_inferring
    
    # ### Description
    #
    # Method used for validation for the usage of an element inside the video or audio editor: it's checked, essentially, that an element exists, and that the user who is using the editor is allowed to use it (see Media::Video::Editing::Parameters and Media::Audio::Editing::Parameters)
    #
    # ### Args
    #
    # * *media_element_id*: the id of the element
    # * *an_user_id*: the id of the User who is using the editor
    # * *my_sti_type*: the sti_type of the requested element
    #
    # ### Returns
    #
    # If the element can be used, it returns an object of type Video, Audio or Image, depending on the element, otherwise it returns +nil+
    #
    # ### Usage
    #
    # See for instance Media::Video::Editing::Parameters.convert_parameters and Media::Video::Editing::Parameters.get_media_element_from_hash
    #   hash[key].kind_of?(Integer) ? MediaElement.extract(hash[key], user_id, my_sti_type) : nil
    #
    def extract(media_element_id, an_user_id, my_sti_type)
      media_element = find_by_id media_element_id
      return nil if media_element.nil? || media_element.sti_type != my_sti_type
      media_element.set_status(an_user_id)
      return nil if media_element.status.nil?
      media_element
    end
    
    # ### Description
    #
    # Checks whether the dashboard of a particular user is empty because he picked all the suggested elements and not because the database is empty (see DashboardController#index).
    #
    # ### Args
    #
    # * *user_id*: the id of a User
    #
    # ### Returns
    #
    # A boolean
    #
    def dashboard_emptied?(an_user_id)
      Bookmark.joins("INNER JOIN media_elements ON media_elements.id = bookmarks.bookmarkable_id AND bookmarks.bookmarkable_type = 'MediaElement'").where('media_elements.is_public = ? AND media_elements.user_id != ? AND bookmarks.user_id = ?', true, an_user_id, an_user_id).any?
    end
    
    # ### Description
    #
    # It extracts the type of an element according to the same white list used in MediaElement#new_with_sti_type_inferring. It's used in User#save_in_admin_quick_uploading_cache (accessor method to save a list of files massively uploaded and ready to be saved as media elements)
    #
    # ### Args
    #
    # * *path*: the path to be checked
    #
    # ### Returns
    #
    # The inferred sti_type
    #
    def filetype(path)
      path = File.extname(path)
      if Audio::EXTENSION_WHITE_LIST.include?(path[1, path.length])
        return 'audio'
      elsif Video::EXTENSION_WHITE_LIST.include?(path[1, path.length])
        return 'video'
      elsif Image::EXTENSION_WHITE_LIST.include?(path[1, path.length])
        return 'image'
      else
        return nil
      end
    end

    def max_media_column_size
      return @max_media_column_size if instance_variable_defined? :@max_media_column_size

      @max_media_column_size = columns_hash['media'].limit
    end
    attr_writer :max_media_column_size
    
  end

  # ### Description
  #
  # Checks if the it is the +lesson+ argument cover
  #
  # ### Returns
  #
  # A boolean-compliant value
  #
  def cover_of?(lesson)
    is_a?(Image) && self == lesson.cover.media_elements.first
  end
  
  def ebook_resources_formats
    self.class::EBOOK_FORMATS
  end

  # ### Description
  #
  # Extracts the translation of the +sti_type+ from the translation file
  #
  # ### Returns
  #
  # A string
  #
  def sti_type_to_s
    I18n.t("sti_types.#{self.sti_type.downcase}")
  end
  
  # ### Description
  #
  # Sets +metadata+.+available_video+ or +metadata+.+available_audio+ to +false+ (depending on sti_type). Used after the editing started for this element, see Media::Shared.
  #
  def disable_lessons_containing_me
    manage_lessons_containing_me(false)
  end
  
  # ### Description
  #
  # Sets +metadata+.+available_video+ or +metadata+.+available_audio+ to +true+ (depending on sti_type). Used when the editing for this element is over (either correclty or with errors): see Media::Video::Editing::Composer and Media::Audio::Editing::Composer.
  #
  def enable_lessons_containing_me
    manage_lessons_containing_me(true)
  end
  
  # ### Description
  #
  # Returns +true+ if the element is of type Image
  #
  # ### Returns
  #
  # A boolean
  #
  def image?
    self.sti_type == IMAGE_TYPE
  end
  
  # ### Description
  #
  # Returns +true+ if the element is of type Audio
  #
  # ### Returns
  #
  # A boolean
  #
  def audio?
    self.sti_type == AUDIO_TYPE
  end
  
  # ### Description
  #
  # Returns +true+ if the element is of type Video
  #
  # ### Returns
  #
  # A boolean
  #
  def video?
    self.sti_type == VIDEO_TYPE
  end
  
  # ### Description
  #
  # It uses Tagging.visive_tags (see also Lesson#visive_tags)
  #
  def visive_tags
    Tagging.visive_tags(self.tags)
  end
  
  # ### Description
  #
  # Used as (unproper) substitute for the attr_reader relative to the attribute +tags+: it extracts the tags directly from the database
  #
  # ### Returns
  #
  # An array of Tag objects.
  #
  def tags
    self.new_record? ? '' : Tag.get_friendly_tags(self)
  end
  
  # ### Description
  #
  # Used as (unproper) substitute for the attribute writer relative to the attribute +tags+: the attribute +tags+ is filled with a string of words separated by comma. During the validation, +tags+ is converted in another attribute called +inner_tags+: this attribute is an array of objects of type Tag (if the tag doesn't exist yet, the object is new_record) ready to be saved together with their taggings in the +after_save+ validation.
  #
  # ### Args
  #
  # Either an array of strings, or a string of words separated by comma
  #
  def tags=(tags)
    @tags = 
      case tags
      when String
        tags
      when Array
        tags.map(&:to_s).join(',')
      end
    @tags
  end
  
  # ### Description
  #
  # Substitute for the attr_reader relative to the attribute +status+.
  #
  # ### Args
  #
  # * *with_captions*: if +true+ returns the translated caption of the status (this means that it's used in the front-end), otherwise it returns the status keyword (for default).
  #
  # ### Returns
  #
  # A string, or a keyword representing the status (see Statuses)
  #
  def status(with_captions=false)
    @status.nil? ? nil : (with_captions ? MediaElement.status(@status) : @status)
  end
  
  # ### Description
  #
  # This function fills the attributes is_reportable, status and info_changeable (the last two being private). If the model has the four of these attributes different by +nil+, it means that the element has a status and the application knows which functionalities are available for the user who requested it. If the status is +nil+, it means that the user can't see this element.
  #
  # ### Args
  #
  # * *an_user_id*: the id of the user who is asking permission to see the element.
  # * *selects*: optionally, a hash of symbols of methods that optimize the extraction of records in other tables, necessary to set the status. These symbols are passed to MediaElement#bookmarked?
  #
  def set_status(an_user_id, selects={})
    return if self.new_record?
    am_i_bookmarked = self.bookmarked?(an_user_id, selects[:bookmarked])
    if !self.is_public && an_user_id == self.user_id
      @status = Statuses::PRIVATE
      @is_reportable = false
      @info_changeable = true
    elsif self.is_public && !am_i_bookmarked
      @status = Statuses::PUBLIC
      @is_reportable = true
      @info_changeable = false
    elsif self.is_public && am_i_bookmarked
      @status = Statuses::LINKED
      @is_reportable = true
      @info_changeable = false
    else
      @status = nil
      @is_reportable = nil
      @info_changeable = nil
    end
  end
  
  # ### Description
  #
  # Returns the list of buttons available for the user who wants to see this element. If the element status hasn't been set yet for that user, or the element is not visible for him, it returns an empty array.
  #
  # ### Returns
  #
  # An array of keywords representing buttons (see Buttons)
  #
  def buttons
    return [] if [@status, @is_reportable, @info_changeable].include?(nil)
    if @status == Statuses::PRIVATE
      return [Buttons::PREVIEW, Buttons::EDIT, Buttons::DESTROY]
    elsif @status == Statuses::PUBLIC
       return [Buttons::PREVIEW, Buttons::ADD]
    elsif @status == Statuses::LINKED
       return [Buttons::PREVIEW, Buttons::EDIT, Buttons::REMOVE]
    else
      return []
    end
  end
  
  # ### Description
  #
  # Checks if the element has a Bookmark for a particular user
  #
  # ### Args
  #
  # * *an_user_id*: the id of the User
  # * *select*: a symbol representing a method that optimizes the extraction of bookmarks (if it's passed it means that the record has been optimized)
  #
  # ### Returns
  #
  # A boolean
  #
  def bookmarked?(an_user_id, select=nil)
    return false if self.new_record?
    return (self.send(select).to_i != 0) if !select.nil?
    Bookmark.where(:user_id => an_user_id, :bookmarkable_type => 'MediaElement', :bookmarkable_id => self.id).any?
  end
  
  # ### Description
  #
  # Substitute for the normal method +destroy+, which additionally adds error messages (necessary for the user experience, used in MediaElementsController#destroy)
  #
  # ### Returns
  #
  # A boolean
  #
  def check_and_destroy
    errors.clear
    if self.new_record?
      errors.add(:base, :problem_destroying)
      return false
    end
    if self.is_public
      errors.add(:base, :cant_destroy_public)
      return false
    end
    old_id = self.id
    begin
      self.destroy
    rescue StandardError
      errors.add(:base, :problem_destroying)
      return false
    end
    if MediaElement.exists?(old_id)
      errors.add(:base, :problem_destroying)
      return false
    end
    true
  end
  
  private
  
  # Validates that the tags are at least the number configured in settings.yml, unless the attribute +save_tags+ is false
  def validate_tags_length
    errors.add(:tags, :are_not_enough) if @save_tags && @inner_tags.length < SETTINGS['min_tags_for_item']
    errors.add(:tags, :too_many) if @save_tags && @inner_tags.length > SETTINGS['max_tags_for_item']
  end
  
  # Callback that updates the taggings associated to the element. If the corresponding Tag doesn't exist yet, it's created
  def update_or_create_tags
    return true if @inner_tags.nil? || !@save_tags
    words = []
    @inner_tags.each do |t|
      raise ActiveRecord::Rollback if t.new_record? && !t.save
      words << t.id
      tagging = Tagging.where(:taggable_id => self.id, :taggable_type => 'MediaElement', :tag_id => t.id).first
      if tagging.nil?
        tagging = Tagging.new
        tagging.taggable_id = self.id
        tagging.taggable_type = 'MediaElement'
        tagging.tag_id = t.id
        raise ActiveRecord::Rollback if !tagging.save
      end
    end
    Tagging.where(:taggable_type => 'MediaElement', :taggable_id => self.id).each do |t|
      t.destroy if !words.include?(t.tag_id)
    end
  end
  
  # Initializes validation objects (see Valid.get_association). It's initialized also the private attribute +inner_tags+
  def init_validation
    @media_element = Valid.get_association self, :id
    @user = Valid.get_association self, :user_id
    @inner_tags =
      if @tags.blank?
        Tag.get_tags_for_item(self.id, 'MediaElement')
      else
        resp_tags = []
        prev_tags = []
        @tags.split(',').each do |t|
          if t.present?
            t = t.to_s.strip.mb_chars.downcase.to_s
            if !prev_tags.include? t
              tag = Tag.find_or_initialize_by(:word => t)
              resp_tags << tag if tag.valid?
            end
            prev_tags << t
          end
        end
        resp_tags
      end
  end
  
  # Validates the size of the attached file, comparing it to the maximum size configured in megabytes in settings.yml
  def validate_size
    if ( (audio? || video?) && media.try(:value).try(:is_a?, ActionDispatch::Http::UploadedFile) && media.value.tempfile.size > MAX_MEDIA_SIZE ) ||
       ( image? && media.present? && media.file.size > MAX_MEDIA_SIZE ) ||
       ( media.is_a?(ActionDispatch::Http::UploadedFile) && media.tempfile.size > MAX_MEDIA_SIZE )
      errors.add(:media, :too_large)
    end
  end
  
  # Validates the presence of all the associated objects
  def validate_associations
    errors.add(:user_id, :doesnt_exist) if @user.nil?
  end
  
  # Validates that +publication_date+ is blank if the element is not public, and that it's present and in the correct format if the element is public
  def validate_publication_date
    if self.is_public
      errors.add(:publication_date, :is_not_a_date) if self.publication_date.blank? || !self.publication_date.kind_of?(Time)
    else
      errors.add(:publication_date, :must_be_blank_if_private) if !self.publication_date.blank?
    end
  end
  
  # If it's new record, it validates that +is_public+ must be false; otherwise, if public it validates that +media+, +title+, +description+, +is_public+, +publication_date+ can't be changed; if private, it validates that +user_id+ can't be changed
  def validate_impossible_changes
    if @media_element.nil?
      errors.add(:is_public, :must_be_false_if_new_record) if self.is_public && !self.skip_public_validations
    else
      errors.add(:sti_type, :cant_be_changed) if @media_element.sti_type != self.sti_type
      if @media_element.is_public
        if !self.skip_public_validations
          errors.add(:media, :cant_be_changed_if_public) if self.changed.include? 'media'
          errors.add(:title, :cant_be_changed_if_public) if @media_element.title != self.title
          errors.add(:description, :cant_be_changed_if_public) if @media_element.description != self.description
          errors.add(:is_public, :cant_be_changed_if_public) if !self.is_public
          errors.add(:publication_date, :cant_be_changed_if_public) if @media_element.publication_date != self.publication_date
        end
      else
        errors.add(:user_id, :cant_be_changed) if @media_element.user_id != self.user_id
      end
    end
  end
  
  # Callback that stops the destruction of a public element; the callback is not fired if destroyable_even_if_public is true
  def stop_if_public
    return true if destroyable_even_if_public
    @media_element = Valid.get_association self, :id
    if @media_element.try(:is_public)
      errors.add :is_public, :undestroyable
      false
    else
      true
    end
  end
  
  # Used as a submethod of MediaElement#disable_lessons_containing_me and MediaElement#enable_lessons_containing_me
  def manage_lessons_containing_me(value)
    MediaElementsSlide.where(:media_element_id => id).each do |mes|
      l = mes.slide.lesson
      if video?
        l.metadata.available_video = value
      elsif audio?
        l.metadata.available_audio = value
      end
      l.save!
    end
  end
  
  # Validates the sum of the media elements folder size to don't exceed the maximum size available
  def validate_maximum_media_elements_folder_size
    errors.add :media, :folder_size_exceeded if Media::Uploader.maximum_media_elements_folder_size_exceeded?
  end
  
end

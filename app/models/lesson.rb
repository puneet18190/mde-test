require 'lessons_media_elements_shared'

# ### Description
#
# ActiveRecord class that corresponds to the table +lessons+.
#
# ### Fields
#
# * *uuid*: UUIDv4, used for ebooks univoque identifying
# * *user_id*: id of the creator of the lesson
# * *school_level_id*: id of the school level of the lesson (which corresponds to the school level of its creator)
# * *subject_id*: id of the subject of the lesson
# * *title*: title
# * *description*: description
# * *is_public*: +true+ if the lesson is visible by other users
# * *parent_id*: reference to another lesson, from which the current lesson has been copied. The value is +nil+ if the lesson hasn't been copied
# * *copied_not_modified*: boolean, set to +true+ only for lessons just copied and not modified yet
# * *token*: token used in the public url of the lesson. Without this token, if the lesson is private, the only user who can see it is the creator
# * *metadata*: contains two keys:
#   * +available_video+: true if the lesson doesn't contain any video in conversion
#   * +available_audio+: true if the lesson doesn't contain any audio in conversion
# * *notified*: boolean, set to false only if the lesson has been modified and its modification not notified to users who have a link of the lesson
#
# ### Associations
#
# * *user*: reference to the User who created the lesson (*belongs_to*)
# * *subject*: Subject associated to the lesson (*belongs_to*)
# * *school_level*: SchoolLevel associated to the creator of the lesson and for transitivity to the lesson (*belongs_to*)
# * *parent*: original lesson from which the lesson was copied (*belongs_to*)
# * *copies*: lessons copied by this lesson (*has_many*)
# * *bookmarks*: links created by other users to this lesson (see Bookmark) (*has_many*)
# * *likes*: likes on the lesson (see Like) (*has_many*)
# * *reports*: reports on the lesson (see Report) (*has_many*)
# * *taggings*: tags associated to the lesson (see Tagging, Tag) (*has_many*)
# * *slides*: slides composing the lesson (see Slide) (*has_many*)
# * *media_elements_slides*: list of instances of media elements inside slides of this lesson (see MediaElementsSlide) (through the class Slide) (*has_many*)
# * *media_elements*: list of media elements attached to slides of this lesson (see MediaElement) (through the class Slide and MediaElementsSlide) (*has_and_belongs_to_many*)
# * *virtual_classroom_lessons*: copies of this lesson into the Virtual Classroom of the creator or other users (see VirtualClassroomLesson) (*has_many*)
#
# ### Validations
#
# * *format* for +uuid+. IMPORTANT: actually this is not validated, there is an inner validation in the database, for technical reasons the validation is not incapsulated in rails. Hence, if the uuid is not valid the database will throw an exception
# * *presence* with numericality and existence of associated record for +user_id+, +subject_id+, +school_level_id+
# * *presence* for +title+ and +description+
# * *presence* of associated object, numericality for +parent_id+ and +parent_id+ must different by +id+, <b>only if different by nil</b>
# * *inclusion* of +is_public+, +copied_not_modified+, +notified+ in [+true+, +false+]
# * *length* of +title+ and +description+ (values configured in the I18n translation file; only for title, if the value is greater than 255 it's set to 255)
# * *uniqueness* of the couple [+parent_id+, +user_id+] <b>if +parent_id+ is not null</b>
# * *if* *new* *record* +is_public+ must be false
# * *if* *public* +copied_not_modified+ must be false. <b>This validation is not fired if skip_public_validations is +true+</b>
# * *modifications* *not* *available* for +uuid+, +user_id+, +parent_id+, +token+
# * *minimum* *number* of tags (configurated in settings.yml), <b>only if the attribute save_tags is set as +true+</b>
#
# ### Callbacks
#
# 1. *before_destroy* destroys associated bookmarks (see Bookmark)
# 2. *before_destroy* destroys associated reports (see Report)
# 3. *before_destroy* destroys associated taggings (see Tagging)
# 4. *before_create* initializes +uuid+ field with a new UUIDv4
# 4. *before_create* initializes both metadata values to +true+
# 5. *before_create* creates a random encoded string and writes it in +token+
# 6. *after_save* creates or updates the cover slide. <b>This callback is not fired if skip_cover_creation is +true+</b>
# 7. *after_save* updates taggings associated to the lesson (see Tagging). If a Tag doesn't exist yet, it is created too. The tags are stored before the validation in the private attribute +inner_tags+
# 8. *cascade* *destruction* for Slide (this was added late to handle math images).
#
# ### Database callbacks
#
# 1. *cascade* *destruction* for the associated table Like
# 2. *cascade* *destruction* for the associated table Slide (this besides the normal destruction cascade, see above).
# 3. *cascade* *destruction* for the associated table VirtualClassroomLesson
# 4. *set* *null* *on* *destruction* on the column +parent_id+ of all the lessons copied by the current lesson
#
# ### Scopes
#
# * *of*: lessons owned by a user (see User#own_lessons). Example (1: user_id):
#   SELECT "lessons".* FROM "lessons" LEFT JOIN bookmarks ON bookmarks.bookmarkable_id = lessons.id AND bookmarks.bookmarkable_type = 'Lesson'
#   AND bookmarks.user_id = 1 ORDER BY COALESCE(bookmarks.created_at, lessons.updated_at) DESC
# * *copiable_by*: lessons copiable by a user (see Lesson#copy). . Example (1: user_id):
#   SELECT "lessons".* FROM "lessons" WHERE (( EXISTS (SELECT * FROM bookmarks WHERE bookmarks.bookmarkable_type = 'Lesson' AND bookmarks.user_id = 1 AND bookmarks.bookmarkable_id = lessons.id) OR lessons.user_id = 1) AND NOT EXISTS (SELECT * FROM lessons AS son_lessons WHERE son_lessons.parent_id = lessons.id AND son_lessons.user_id = 1) AND lessons.copied_not_modified = FALSE)
#
class Lesson < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  extend LessonsMediaElementsShared
  
  # Maximum length of the title
  MAX_TITLE_LENGTH = (I18n.t('language_parameters.lesson.length_title') > 255 ? 255 : I18n.t('language_parameters.lesson.length_title'))
    
  # True if in the front end the element contains the icon to send a report
  attr_reader :is_reportable
  # Set to true if it's necessary to validate the number of tags (typically this happens in the public front end)
  attr_writer :save_tags
  # Set to true if it's necessary to skip cover creation (used in seeding)
  attr_accessor :skip_cover_creation
  # Set to true if it's necessary to skip public validations (used in seeding)
  attr_accessor :skip_public_validations
  
  serialize :metadata, OpenStruct
  
  belongs_to :user
  belongs_to :subject
  belongs_to :school_level
  belongs_to :parent, :class_name => 'Lesson', :foreign_key => :parent_id
  has_many :copies, :class_name => 'Lesson', :foreign_key => :parent_id
  has_many :bookmarks, :as => :bookmarkable, :dependent => :destroy
  has_many :likes
  has_many :reports, :as => :reportable, :dependent => :destroy
  has_many :taggings, :as => :taggable, :dependent => :destroy
  has_many :tags_through_taggings, :through => :taggings, :source => :tag
  has_many :slides, :dependent => :destroy
  has_many :media_elements_slides, :through => :slides
  has_many :media_elements, -> { uniq }, :through => :media_elements_slides
  has_many :documents_slides, :through => :slides
  has_many :documents, -> { uniq }, :through => :documents_slides
  has_many :virtual_classroom_lessons
  
  validates_presence_of :user_id, :school_level_id, :subject_id, :title, :description
  validates_numericality_of :user_id, :school_level_id, :subject_id, :only_integer => true, :greater_than => 0
  validates_numericality_of :parent_id, :only_integer => true, :greater_than => 0, :allow_nil => true
  validates_inclusion_of :is_public, :copied_not_modified, :notified, :in => [true, false]
  validates_length_of :title, :maximum => MAX_TITLE_LENGTH
  validates_length_of :description, :maximum => I18n.t('language_parameters.lesson.length_description')
  validates_uniqueness_of :parent_id, :scope => :user_id, :if => :present_parent_id
  validate :validate_associations, :validate_public, :validate_copied_not_modified_and_public, :validate_impossible_changes, :validate_tags_length
  
  before_validation :init_validation
  before_create :create_uuid, :initialize_metadata, :create_token
  after_save :create_or_update_cover, :update_or_create_tags
  
  scope :of, ->(user_or_user_id) do
    user_id = user_or_user_id.is_a?(User) ? user_or_user_id.id : user_or_user_id
    joins(sanitize_sql [ "LEFT JOIN bookmarks ON 
                          bookmarks.bookmarkable_id = lessons.id AND 
                          bookmarks.bookmarkable_type = 'Lesson' AND 
                          bookmarks.user_id = %i", user_id ] ).
    where('bookmarks.user_id IS NOT NULL OR lessons.user_id = ?', user_id).
    order('COALESCE(bookmarks.created_at, lessons.updated_at) DESC')
  end
  
  # Important! This scope has not been tested, it shoudln't be used in the application but only in the console!!!
  scope :copiable_by, ->(user_or_user_id) do
    where("(EXISTS (SELECT * FROM bookmarks WHERE bookmarks.bookmarkable_type = 'Lesson' AND bookmarks.user_id = :user_id AND bookmarks.bookmarkable_id = lessons.id) OR lessons.user_id = :user_id) AND NOT EXISTS (SELECT * FROM lessons AS son_lessons WHERE son_lessons.parent_id = lessons.id AND son_lessons.user_id = :user_id) AND lessons.copied_not_modified = FALSE", user_id: user_or_user_id)
  end
  
  # ### Description
  #
  # Send a notification (containing the details of modifications) to all the users who have a link of the lesson. This method is called only if the link was created *before* that the lesson was modified. The method also sets +notified+ as +true+. Used in LessonsController#notify_modification.
  #
  # ### Args
  #
  # * *msg*: details of the modifications
  #
  # ### Returns
  #
  # A boolean.
  #
  def notify_changes(msg)
    Bookmark.where('bookmarkable_type = ? AND bookmarkable_id = ? AND created_at < ?', 'Lesson', self.id, self.updated_at).each do |bo|
      message_max = I18n.t('language_parameters.notification.message_length_for_public_lesson_modification')
      message = msg.blank? ? I18n.t('lessons.notify_modifications.empty_message') : msg[0, message_max]
      Notification.send_to(
        bo.user_id,
        I18n.t('notifications.lessons.modified.title'),
        I18n.t('notifications.lessons.modified.message', :lesson_title => self.title, :message => message),
        I18n.t('notifications.lessons.modified.basement', :lesson_title => self.title, :link => lesson_viewer_path(self.id))
      )
    end
    self.notified = true
    self.save
  end
  
  # ### Description
  #
  # Sets +notified+ as +true+ without sending the notification of modifications (see Lesson#notify_changes). Used in LessonsController#dont_notify_modification.
  #
  # ### Returns
  #
  # A boolean.
  #
  def dont_notify_changes
    self.notified = true
    self.save
  end
  
  # ### Description
  #
  # Checks whether the lesson is available for editing in the Lesson Editor (if at least one between +metadata+.+available_audio+ and +metadata+.+available_video+ is false, the lesson is not available). Used in the filters of LessonEditorController.
  #
  # ### Args
  #
  # * *type*: if the parameter is inserted explicitly, the methods returns only the value for the specific type; otherwise it returns +available_video+ && +available_audio+.
  #
  # ### Returns
  #
  # A boolean.
  #
  def available?(type=nil)
    case type = type.to_s.downcase
    when 'video', 'audio'
      metadata.send :"available_#{type}"
    else
      metadata.available_video && metadata.available_audio
    end
  end
  
  # ### Description
  #
  # Sets the value of one of the two metadata (+available_video+ or +available_audio+).
  #
  # ### Args
  #
  # * *type*: used to select which of the two metadata is going to be set
  # * *value*: +true+ for default.
  #
  def available!(type, value=true)
    metadata.send :"available_#{type.to_s.downcase}=", !!value
    update_attribute(:metadata, metadata)
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
  
  # Gets the last slide of this lesson
  def last_slide
    Slide.order('position DESC').where(:lesson_id => self.id).first
  end
  
  # ### Description
  #
  # Returns the cover slide of the lesson.
  #
  # ### Returns
  #
  # An object of type Slide, or +nil+ if the lesson is new_record
  #
  def cover
    return nil if self.new_record?
    Slide.where(:kind => Slide::COVER, :lesson_id => self.id).first
  end
  
  # ### Description
  #
  # Checks whether the dashboard of a particular user is empty because he picked all the suggested lessons and not because the database is empty (see DashboardController#index).
  #
  # ### Args
  #
  # * *user_id*: the id of a User
  #
  # ### Returns
  #
  # A boolean
  #
  def self.dashboard_emptied?(an_user_id)
    subject_ids = []
    UsersSubject.where(:user_id => an_user_id).each do |us|
      subject_ids << us.subject_id
    end
    Bookmark.joins("INNER JOIN lessons ON lessons.id = bookmarks.bookmarkable_id AND bookmarks.bookmarkable_type = 'Lesson'").where('lessons.is_public = ? AND lessons.user_id != ? AND lessons.subject_id IN (?) AND bookmarks.user_id = ?', true, an_user_id, subject_ids, an_user_id).any?
  end

  # Returns the math images related to the slides of the lesson. If +modality+ is +:full_path+ it returns the absolute path, otherwise it returns the file names (the default value is +nil+). The results are unique.
  def math_images_paths(modality = nil)
    slides.map{ |r| r.math_images.to_a(modality) }.flatten.uniq{ |v| v.basename }
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
  # A string, or a keyword representing the status (see Statuses and LessonsMediaElementsShared)
  #
  def status(with_captions=false)
    @status.nil? ? nil : (with_captions ? Lesson.status(@status) : @status)
  end
  
  # ### Description
  #
  # This function fills the attributes is_reportable, status, in_vc and linked (the last three being private). If the model has the four of these attributes different by +nil+, it means that the lesson has a status and the application knows which functionalities are available for the user who requested it. If the status is +nil+, it means that the user can't see this lesson.
  #
  # ### Args
  #
  # * *an_user_id*: the id of the user who is asking permission to see the lesson.
  # * *selects*: optionally, a hash of symbols of methods that optimize the extraction of records in other tables, necessary to set the status. These symbols are passed to Lesson#bookmarked?, Lesson#in_virtual_classroom? and Lesson#liked?
  #
  def set_status(an_user_id, selects={})
    return if self.new_record?
    am_i_bookmarked = self.bookmarked?(an_user_id, selects[:bookmarked])
    if !self.is_public && !self.copied_not_modified && an_user_id == self.user_id
      @status = Statuses::PRIVATE
      @is_reportable = false
    elsif !self.is_public && self.copied_not_modified && an_user_id == self.user_id
      @status = Statuses::COPIED
      @is_reportable = false
    elsif self.is_public && an_user_id != self.user_id && am_i_bookmarked
      @status = Statuses::LINKED
      @is_reportable = true
    elsif self.is_public && an_user_id != self.user_id && !am_i_bookmarked
      @status = Statuses::PUBLIC
      @is_reportable = true
    elsif self.is_public && an_user_id == self.user_id
      @status = Statuses::SHARED
      @is_reportable = false
    else
      @status = nil
      @is_reportable = nil
    end
    @in_vc = self.in_virtual_classroom?(an_user_id, selects[:in_vc])
    @liked = self.liked?(an_user_id, selects[:liked])
    true
  end
  
  # ### Description
  #
  # Returns the list of buttons available for the user who wants to see this lesson. If the lesson status hasn't been set yet for that user, or the lesson is not visible for him, it returns an empty array.
  #
  # ### Returns
  #
  # An array of keywords representing buttons (see Buttons)
  #
  def buttons
    return [] if [@status, @in_vc, @liked, @is_reportable].include?(nil)
    case @status
    when Statuses::PRIVATE
      [Buttons::PREVIEW, Buttons::EDIT, virtual_classroom_button, Buttons::PUBLISH, Buttons::COPY, Buttons::DESTROY]
    when Statuses::COPIED
      [Buttons::PREVIEW, Buttons::EDIT, Buttons::DESTROY]
    when Statuses::LINKED
      [Buttons::PREVIEW, Buttons::COPY, virtual_classroom_button, like_button, Buttons::REMOVE]
    when Statuses::PUBLIC
      [Buttons::PREVIEW, Buttons::ADD, like_button]
    when Statuses::SHARED
      [Buttons::PREVIEW, Buttons::EDIT, virtual_classroom_button, Buttons::UNPUBLISH, Buttons::COPY, Buttons::DESTROY]
    else
      []
    end
  end
  
  # ### Description
  #
  # Checks if the lesson has a Bookmark for a particular user
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
    Bookmark.where(:user_id => an_user_id, :bookmarkable_type => 'Lesson', :bookmarkable_id => self.id).any?
  end
  
  # ### Description
  #
  # Creates a copy of the lesson for a particular user. First, it checks if that user is allowed to copy the lesson (he must be the owner of the lesson, or alternatively he must have a bookmark for that lesson). Then the method checks if the user hasn't already copied the lesson. Then it copies, in sequence:
  # 1. the lesson with the cover
  # 2. the slides (see Slide)
  # 3. the media elements attached (see MediaElementsSlide)
  # 4. the tags (see Tagging).
  # Used in LessonsController#copy.
  #
  # ### Args
  #
  # * *an_user_id*: the id of the User who is copying the lesson
  #
  # ### Returns
  #
  # If the process ended correctly, the object of the new lesson,  otherwise +nil+
  #
  def copy(an_user_id)
    errors.clear
    if self.new_record? || User.where(:id => an_user_id).empty? || (!self.is_public && self.user_id != an_user_id) || (self.is_public && self.user_id != an_user_id && Bookmark.where(:bookmarkable_type => 'Lesson', :bookmarkable_id => self.id, :user_id => an_user_id).empty?)
      errors.add(:base, :problem_copying)
      return nil
    end
    if Lesson.where(:parent_id => self.id, :user_id => an_user_id).any?
      errors.add(:base, :already_copied)
      return nil
    end
    if self.copied_not_modified
      errors.add(:base, :just_copied)
      return nil
    end
    resp = nil
    ActiveRecord::Base.transaction do
      lesson = Lesson.new :subject_id => self.subject_id, :school_level_id => self.school_level_id, :title => self.title, :description => self.description
      lesson.copied_not_modified = true
      lesson.user_id = an_user_id
      lesson.parent_id = self.id
      lesson.tags = self.tags
      lesson.save_tags = true
      if !lesson.save
        errors.add(:base, :problem_copying)
        raise ActiveRecord::Rollback
      end
      new_cover = Slide.where(:lesson_id => lesson.id, :position => 1).first
      if new_cover.nil?
        errors.add(:base, :problem_copying)
        raise ActiveRecord::Rollback
      end
      cover = Slide.where(:lesson_id => self.id, :position => 1).first
      cover_image = MediaElementsSlide.where(:slide_id => cover.id).first
      if cover_image
        new_cover_image = MediaElementsSlide.new
        new_cover_image.media_element_id = cover_image.media_element_id
        new_cover_image.slide_id = new_cover.id
        new_cover_image.position = 1
        new_cover_image.alignment = cover_image.alignment
        new_cover_image.caption = cover_image.caption
        if !new_cover_image.save
          errors.add(:base, :problem_copying)
          raise ActiveRecord::Rollback
        end
      end
      Slide.where('lesson_id = ? AND position > 1', self.id).order(:position).each do |s|
        new_slide = Slide.new :position => s.position, :title => s.title, :text => s.text
        new_slide.lesson_id = lesson.id
        new_slide.kind = s.kind
        new_slide.math_images = s.math_images
        if !new_slide.save
          errors.add(:base, :problem_copying)
          raise ActiveRecord::Rollback
        end
        MediaElementsSlide.where(:slide_id => s.id).each do |mes|
          new_content = MediaElementsSlide.new
          new_content.media_element_id = mes.media_element_id
          new_content.slide_id = new_slide.id
          new_content.position = mes.position
          new_content.alignment = mes.alignment
          new_content.caption = mes.caption
          if !new_content.save
            errors.add(:base, :problem_copying)
            raise ActiveRecord::Rollback
          end
        end
        if s.allows_document?
          DocumentsSlide.where(:slide_id => s.id).each do |ds|
            new_document = DocumentsSlide.new
            new_document.slide_id = new_slide.id
            new_document.document_id = ds.document_id
            if !new_document.save
              errors.add(:base, :problem_copying)
              raise ActiveRecord::Rollback
            end
          end
        end
      end
      resp = lesson
    end
    resp
  end
  
  # ### Description
  #
  # Returns a string of tags separated by comma and space ("tag1, tag2, tag3"), by calling a class method of Tag. This is necessary for the front end, since in the backend tags are managed without spaces and with two additional commas in the beginning and in the end of the string (",tag1,tag2,tag3,"). It uses Tagging.visive_tags (see also MediaElement#visive_tags)
  #
  # ### Returns
  #
  # A string
  #
  def visive_tags
    Tagging.visive_tags(self.tags)
  end
  
  # ### Description
  #
  # A method that sets all the fields that must be updated at any time the lesson or one of its slides is modified (that is, this method is related to the models Lesson, Slide and MediaElementsSlide).
  #
  # ### Returns
  #
  # A boolean
  #
  def modify
    self.copied_not_modified = false
    self.notified = false
    self.save
  end
  
  # ### Description
  #
  # Sets +is_public+ as +true+ for the lesson and for each private MediaElement attached to the lesson through MediaElementsSlide and Slide. Used in LessonsController#publish.
  #
  # ### Returns
  #
  # A boolean
  #
  def publish
    errors.clear
    pub_date = Time.zone.now
    if self.new_record?
      errors.add(:base, :problem_publishing)
      return false
    end
    if self.is_public
      errors.add(:base, :already_published)
      return false
    end
    resp = false
    ActiveRecord::Base.transaction do
      self.is_public = true
      if !self.save
        errors.add(:base, :problem_publishing)
        raise ActiveRecord::Rollback
      end
      Slide.where(:lesson_id => self.id).each do |s|
        MediaElementsSlide.where(:slide_id => s.id).each do |mes|
          me = mes.media_element
          if !me.is_public
            me.is_public = true
            me.publication_date = pub_date
            if !me.save
              errors.add(:base, :problem_publishing)
              raise ActiveRecord::Rollback
            end
            boo = Bookmark.new
            boo.user_id = self.user_id
            boo.bookmarkable_type = 'MediaElement'
            boo.bookmarkable_id = me.id
            if !boo.save
              errors.add(:base, :problem_publishing)
              raise ActiveRecord::Rollback
            end
          end
        end
      end
      resp = true
    end
    resp
  end
  
  # ### Description
  #
  # Sets +is_public+ as +false+, deletes all bookmarks (see Bookmark) and copies in Virtual Classroom (see VirtualClassroomLesson) associated to the present lesson. Also, sends a notification to all the user who lost a bookmark of the lesson. Used in LessonsController#unpublish.
  #
  # ### Returns
  #
  # A boolean
  #
  def unpublish
    errors.clear
    if self.new_record?
      errors.add(:base, :problem_unpublishing)
      return false
    end
    if !self.is_public
      errors.add(:base, :already_unpublished)
      return false
    end
    resp = false
    ActiveRecord::Base.transaction do
      Bookmark.where(:bookmarkable_type => 'Lesson', :bookmarkable_id => self.id).each do |b|
        begin
          n_title = I18n.t('notifications.lessons.unpublished.title')
          n_message = I18n.t('notifications.lessons.unpublished.message', :user_name => self.user.full_name, :lesson_title => self.title)
          if !Notification.send_to(b.user_id, n_title, n_message, '')
            errors.add(:base, :problem_unpublishing)
            raise ActiveRecord::Rollback
          end
          b.destroy
        rescue StandardError
          errors.add(:base, :problem_unpublishing)
          raise ActiveRecord::Rollback
        end
      end
      self.is_public = false
      if !self.save
        errors.add(:base, :problem_unpublishing)
        raise ActiveRecord::Rollback
      end
      resp = true
    end
    resp
  end
  
  # ### Description
  #
  # Destroys the lesson and sends notifications to the users who had a Bookmark of it (the bookmarks are destroyed by the +before_destroy+ callback). Used in LessonsController#destroy.
  #
  # ### Returns
  #
  # A boolean
  #
  def destroy_with_notifications
    errors.clear
    if self.new_record?
      errors.add(:base, :problem_destroying)
      return false
    end
    resp = false
    ActiveRecord::Base.transaction do
      Bookmark.where(:bookmarkable_type => 'Lesson', :bookmarkable_id => self.id).each do |b|
        n_title = I18n.t('notifications.lessons.destroyed.title')
        n_message = I18n.t('notifications.lessons.destroyed.message', :user_name => self.user.full_name, :lesson_title => self.title)
        if !Notification.send_to(b.user_id, n_title, n_message, '')
          errors.add(:base, :problem_destroying)
          raise ActiveRecord::Rollback
        end
      end
      begin
        self.destroy
      rescue StandardError
        errors.add(:base, :problem_destroying)
        raise ActiveRecord::Rollback
      end
      resp = true
    end
    resp
  end
  
  # ### Description
  #
  # Adds a slide of a specific type. Used in LessonEditorController#add_slide
  #
  # ### Args
  #
  # * *kind*: the template chosen for the new slide
  # * *position*: the position in which the new slide must be inserted
  #
  # ### Returns
  #
  # A boolean
  #
  def add_slide(kind, position)
    if self.new_record? || !Slide::KINDS_WITHOUT_COVER.include?(kind)
      return nil
    end
    resp = nil
    ActiveRecord::Base.transaction do
      slide = Slide.new
      slide.kind = kind
      slide.lesson_id = self.id
      slide.position = self.last_slide.position + 1
      raise ActiveRecord::Rollback if !slide.save || !slide.change_position(position) || !self.modify
      resp = slide
    end
    resp
  end
  
  # ### Description
  #
  # Checks if the maximum number of slides has been reached by this lesson (this number is configured in settings.yml). Used in the validations of Slide.
  #
  # ### Returns
  #
  # A boolean
  #
  def reached_the_maximum_of_slides?
    Slide.where(:lesson_id => self.id).count == SETTINGS['max_number_slides_in_a_lesson']
  end
  
  # ### Description
  #
  # Creates a record of VirtualClassroomLesson for this lesson. First it checks whether the record can be created or not (for instance, it is not possible if the user is not owner of the lesson and doesn't have a bookmark for it). Used in VirtualClassroomController#add_lesson and in VirtualClassroomController#load_lessons.
  #
  # ### Args
  #
  # * *an_user_id*: the id of the User who is adding the lesson to his Virtual Classroom
  #
  # ### Returns
  #
  # A boolean
  #
  def add_to_virtual_classroom(an_user_id)
    errors.clear
    if self.new_record?
      errors.add(:base, :problem_adding_to_virtual_classroom)
      return false
    end
    if User.where(:id => an_user_id).empty?
      errors.add(:base, :problem_adding_to_virtual_classroom)
      return false
    end
    if VirtualClassroomLesson.where(:lesson_id => self.id, :user_id => an_user_id).any?
      errors.add(:base, :lesson_already_in_virtual_classroom)
      return false
    end
    vc = VirtualClassroomLesson.new
    vc.user_id = an_user_id
    vc.lesson_id = self.id
    if !vc.save
      errors.add(:base, :lesson_not_available_for_virtual_classroom)
      return false
    end
    true
  end
  
  # ### Description
  #
  # Removes the associated record of VirtualClassroomLesson for a particular User, if any. Used in VirtualClassroomController#remove_lesson and in VirtualClassroomController#remove_lesson_from_inside.
  #
  # ### Args
  #
  # * *an_user_id*: the id of the User
  #
  # ### Returns
  #
  # A boolean
  #
  def remove_from_virtual_classroom(an_user_id)
    errors.clear
    if self.new_record?
      errors.add(:base, :problem_removing_from_virtual_classroom)
      return false
    end
    if User.where(:id => an_user_id).empty?
      errors.add(:base, :problem_removing_from_virtual_classroom)
      return false
    end
    vc = VirtualClassroomLesson.where(:lesson_id => self.id, :user_id => an_user_id).first
    return true if vc.nil?
    if !vc.remove_from_playlist
      errors.add(:base, :problem_removing_from_virtual_classroom)
      return false
    end
    begin
      VirtualClassroomLesson.find(vc.id).destroy
    rescue
      errors.add(:base, :problem_removing_from_virtual_classroom)
      return false
    end
    true
  end
  
  # ### Description
  #
  # Checks if the lesson has a corresponding VirtualClassroomLesson for a specific USer
  #
  # ### Args
  #
  # * *an_user_id*: the id of the User
  # * *select*: a symbol representing a method that optimizes the extraction of virtual classroom lessons (if it's passed it means that the record has been optimized)
  #
  # ### Returns
  #
  # A boolean
  #
  def in_virtual_classroom?(an_user_id, select=nil)
    return false if self.new_record?
    return (self.send(select).to_i != 0) if !select.nil?
    VirtualClassroomLesson.where(:user_id => an_user_id, :lesson_id => self.id).any?
  end
  
  # ### Description
  #
  # Checks if there is a record of Like for a particular User
  #
  # ### Args
  #
  # * *an_user_id*: the id of the User
  # * *select*: a symbol representing a method that optimizes the extraction of likes (if it's passed it means that the record has been optimized)
  #
  # ### Returns
  #
  # A boolean
  #
  def liked?(an_user_id, select=nil)
    return false if self.new_record?
    return (self.send(select).to_i != 0) if !select.nil?
    Like.where(:user_id => an_user_id, :lesson_id => self.id).any?
  end
  
  private
  
  # Validates that the tags are at least the number configured in settings.yml, unless the attribute +save_tags+ is false
  def validate_tags_length
    errors.add(:tags, :are_not_enough) if @save_tags && @inner_tags.length < SETTINGS['min_tags_for_item']
    errors.add(:tags, :too_many) if @save_tags && @inner_tags.length > SETTINGS['max_tags_for_item']
  end
  
  # Extracts the corresponding button depending on the fact that the lesson is in the Virtual Classroom or not
  def virtual_classroom_button
    @in_vc ? Buttons::REMOVE_VIRTUAL_CLASSROOM : Buttons::ADD_VIRTUAL_CLASSROOM
  end
  
  # Extracts the corresponding button depending on the fact that the lesson is liked by the user or not
  def like_button
    @liked ? Buttons::DISLIKE : Buttons::LIKE
  end
  
  # Checks if +parent_id+ != +nil+
  def present_parent_id
    self.parent_id
  end
  
  # Validates the presence of all the associated objects; only for +parent_id+, it's allowed +nil+, and if not +nil+ it's checked that it's not the lesson itself
  def validate_associations
    errors.add(:user_id, :doesnt_exist) if @user.nil?
    errors.add(:subject_id, :doesnt_exist) if @subject.nil?
    errors.add(:school_level_id, :doesnt_exist) if @school_level.nil?
    errors.add(:parent_id, :doesnt_exist) if self.parent_id && @parent.nil?
    errors.add(:parent_id, :cant_be_the_lesson_itself) if @lesson && self.parent_id == @lesson.id
  end
  
  # Callback that updates the taggings associated to the lesson. If the corresponding Tag doesn't exist yet, it's created
  def update_or_create_tags
    return true if @inner_tags.nil? || !@save_tags
    words = []
    @inner_tags.each do |t|
      raise ActiveRecord::Rollback if t.new_record? && !t.save
      words << t.id
      tagging = Tagging.where(:taggable_id => self.id, :taggable_type => 'Lesson', :tag_id => t.id).first
      if tagging.nil?
        tagging = Tagging.new
        tagging.taggable_id = self.id
        tagging.taggable_type = 'Lesson'
        tagging.tag_id = t.id
        raise ActiveRecord::Rollback if !tagging.save
      end
    end
    Tagging.where(:taggable_type => 'Lesson', :taggable_id => self.id).each do |t|
      t.destroy if !words.include?(t.tag_id)
    end
  end
  
  # Initializes validation objects (see Valid.get_association). It's initialized also the private attribute +inner_tags+
  def init_validation
    @lesson = Valid.get_association self, :id
    @user = Valid.get_association self, :user_id
    @subject = Valid.get_association self, :subject_id
    @school_level = Valid.get_association self, :school_level_id
    @parent = Valid.get_association self, :parent_id, Lesson
    @title_changed = (@lesson && @lesson.title != self.title)
    if @tags.blank?
      @inner_tags = Tag.get_tags_for_item(self.id, 'Lesson')
    else
      resp_tags = []
      prev_tags = []
      @tags.split(',').each do |t|
        if !t.blank?
          t = t.to_s.strip.mb_chars.downcase.to_s
          if !prev_tags.include? t
            tag = Tag.find_by_word t
            tag = Tag.new(:word => t) if tag.nil?
            resp_tags << tag if tag.valid?
          end
          prev_tags << t
        end
      end
      @inner_tags = resp_tags
    end
  end
  
  # Callback that creates or updates the cover after save
  def create_or_update_cover
    if @lesson.nil?
      return true if skip_cover_creation
      slide = Slide.new :title => self.title, :position => 1
      slide.kind = Slide::COVER
      slide.lesson_id = self.id
      slide.save
    elsif @title_changed
      my_cover = self.cover
      my_cover.title = self.title
      my_cover.save
    end
  end
  
  # Validates that a new lesson can't be public
  def validate_public
    errors.add(:is_public, :cant_be_true_for_new_records) if @lesson.nil? && self.is_public && !self.skip_public_validations
  end
  
  # Validates that a lesson just copied can't be public
  def validate_copied_not_modified_and_public
    errors.add(:copied_not_modified, :cant_be_true_if_public) if self.is_public && self.copied_not_modified
  end
  
  # Validates that if the lesson is not new record the fields +token+, +user_id+, +parent_id+ cannot be changed
  def validate_impossible_changes
    if @lesson
      errors.add(:token, :cant_be_changed) if @lesson.token != self.token
      errors.add(:user_id, :cant_be_changed) if @lesson.user_id != self.user_id
      errors.add(:parent_id, :cant_be_changed) if self.parent_id && @lesson.parent_id != self.parent_id
      errors.add(:uuid, :cant_be_changed) if self.uuid_changed?
    end
  end
  
  # Callback that creates a random secure token and sets is as the +token+ of the lesson
  def create_token
    self.token = SecureRandom.urlsafe_base64(16)
    true
  end
  
  # Initialize metadata
  def initialize_metadata
    self.metadata.available_video = true
    self.metadata.available_audio = true
  end
  
  # Create UUIDv4; IMPORTANT, this callback could be skipped, since the same uuid is automatically created in the database (default, there is a function for safety)
  def create_uuid
    self.uuid = ActiveRecord::DB_DEFAULT unless self.uuid
    true
  end
  
end

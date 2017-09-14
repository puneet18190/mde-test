# ### Description
#
# ActiveRecord class that corresponds to the table +users+.
#
# ### Fields
#
# * *email*: unique identifier for the user, and e-mail address
# * *name*: name of the user
# * *surname*: surname of the user
# * *school_level_id*: reference to the user's SchoolLevel
# * *encrypted_password*: password, encrypted with SecureRandom
# * *confirmed*: boolean, +true+ if the user has completed the registration procedure clicking on a link he received by email
# * *active*: boolean, false if the user is banned
# * *location_id*: location of the user
# * *purchase_id*: references to the Purchase that allows the user to log in
# * *confirmation_token*: token used for confirmation, generated automaticly
# * *password_token*: token used for resetting the password, generated automaticly
# * *metadata*:
#   * +video_editor_cache+: cache of the Video Editor (screenshot of the last video edited)
#   * +audio_editor_cache+: cache of the Audio Editor (screenshot of the last audio edited)
#
# ### Associations
#
# * *bookmarks*: links created by this user elements or lessons (see Bookmark) (*has_many*)
# * *notifications*: notifications of this user (see Notification) (*has_many*)
# * *likes*: list of "I like you" registered by this user on other users' lessons (see Like) (*has_many*)
# * *lessons*: list of lessons created by this user (see Lesson) (*has_many*)
# * *media_elements*: list of elements loaded or created by this user (includes also public elements, which are moved into the public database of the application, but they still record who was the user who first created them (see MediaElement, Audio, Image, Video) (*has_many*)
# * *reports*: reports sent by this user about elements or lessons (see Report) (*has_many*)
# * *users_subjects*: list of instances of this subject associated to this user through records of UsersSubject (*has_many*)
# * *subjects*: list of subjects associated to this user (through the association +users_subjects+) (see Subject) (*has_and_belongs_to_many*)
# * *virtual_classroom_lessons*: list of lessons present in the user's Virtual Classroom (see VirtualClassroomLesson) (*has_many*)
# * *mailing_list_groups*: all the mailing list groups that this user created (see MailingListGroup) (*has_many*)
# * *school_level*: the SchoolLevel associated to this user (*belongs_to*)
# * *location*: the Location associated to this user (*belongs_to*, it can be nil)
# * *documents*: documents uploaded by the user (see Document) (*has_many*)
# * *purchase*: the Purchase allowing the user to be logged in with his account
#
# ### Validations
#
# * *presence* of +email+, +name+, +surname+
# * *presence* with numericality greater than 0 and presence of associated object for +school_level_id+
# * *numericality* greater than 0 and allow_nil and eventually presence of associated object for +location_id+ and +purchase_id+ (for the location, it's also checked that the subclass is the last in the locations chain, see Location)
# * *confirmation* of +encrypted_password+ (the attribute password must coincide with its confirmation provided by the user): this validation uses the private attribute +password_confirmation+, associated to password
# * *confirmation* of +email+ (the attribute email must coincide with its confirmation provided by the user): this validation uses the private attribute +email_confirmation+
# * *presence* of at least one associated record of UsersSubject
# * *uniqueness* of +email+
# * *length* of +name+ and +surname+ (maximum 255)
# * *length* of the attribute password associated to +encrypted_password+ (the maximum is configured in settings.yml, same as the minimum, but the minimum can be null, in which case the minimum size is one character). Since this attribute doesn't correspond to a field, the validation is forced only when the user is created: when the user is updated, instead, the validation allows +nil+ and +blank+ values, in case the user doesn't want to change his password
# * *inclusion* of +active+ and +confirmed+ in [+true+, +false+]
# * *correctness* of +email+ as an e-mail address
# * *modifications* *not* *available* for +email+ if the user is not a new record
# * *acceptance* of each policy configured in settings.yml
# * *control* that accounts_number in purchase is less than users count associated to that Purchase (if purchase_id is not nil)
#
# ### Callbacks
#
# 1. *before_destroy* destroys associated instances of subjects (see UsersSubject)
#
# ### Database callbacks
#
# 1. *cascade* *destruction* for the associated table MailingListGroup
#
class User < ActiveRecord::Base
  include Authentication
  include Confirmation
  include ResetPassword
  
  # List of registration policies, configured in settings.yml
  REGISTRATION_POLICIES = SETTINGS['user_registration_policies'].map(&:to_sym)
  
  # The attribute used as a handler for the field +encrypted_password+
  attr_accessor :password
  serialize :metadata, OpenStruct
  
  # List of attributes to be made accessible (the list includes private attributes that don't correspond to fields, for instance +password_confirmation+)
  ATTR_ACCESSIBLE = [:password, :password_confirmation, :name, :surname, :school_level_id, :location_id, :subject_ids, :purchase_id] + REGISTRATION_POLICIES  
  # Hash of constraints for the length of the password
  PASSWORD_LENGTH_CONSTRAINTS = {}.tap do |hash|
    [:minimum, :maximum].each do |key|
      length = SETTINGS["#{key}_password_length"]
      hash[key] = length if length
    end
  end
  
  # ### Description
  #
  # Returns the class of the last Location class (the one that must be attached to a user). The method is defined in this model and not in Location because it's necessary for the association +location+
  #
  # ### Returns
  #
  # An object of type Class
  #
  def self.location_association_class
    Location::SUBMODELS.last
  end
  
  has_many :bookmarks
  has_many :notifications
  has_many :likes
  has_many :lessons
  has_many :media_elements
  has_many :reports
  has_many :users_subjects, :dependent => :destroy
  has_many :subjects, :through => :users_subjects
  has_many :virtual_classroom_lessons
  has_many :mailing_list_groups
  has_many :documents
  belongs_to :school_level
  belongs_to :purchase
  belongs_to :location, :class_name => location_association_class
  
  validates_presence_of :email, :name, :surname, :school_level_id
  validates_numericality_of :school_level_id, :only_integer => true, :greater_than => 0
  validates_numericality_of :location_id, :purchase_id, :only_integer => true, :greater_than => 0, :allow_nil => true
  validates_confirmation_of :password, :email
  validates_presence_of :users_subjects
  validates_uniqueness_of :email
  validates_length_of :name, :surname, :email, :maximum => 255
  validates_length_of :password, PASSWORD_LENGTH_CONSTRAINTS.merge(:on => :create, :unless => proc { |record| record.encrypted_password.present? })
  validates_length_of :password, PASSWORD_LENGTH_CONSTRAINTS.merge(:on => :update, :allow_nil => true, :allow_blank => true)
  validates_inclusion_of :active, :confirmed, :in => [true, false]
  validate :validate_associations, :validate_email
  validate :validate_email_not_changed, :on => :update
  validate :validate_accounts_number_for_purchase
  REGISTRATION_POLICIES.each do |policy|
    validates_acceptance_of policy, on: :create, allow_nil: false
  end
  
  before_validation :init_validation
  
  scope :confirmed,     ->() { where(confirmed: true) }
  scope :not_confirmed, ->() { where(confirmed: false) }
  scope :active,        ->() { where(active: true) }
  
  alias_attribute :"#{SETTINGS['location_types'].last.downcase}", :location
  
  # ### Description
  #
  # It returns an instance of the only super administrator
  #
  # ### Returns
  #
  # An object of type User
  #
  def self.admin
    find_by_email SETTINGS['super_admin']
  end
  
  # ### Description
  #
  # It checks if the user is administrator or not (i.e., if the user is allowed to enter in the administration module, see for instance Admin::DashboardController)
  #
  # ### Returns
  #
  # A boolean
  #
  def admin?
    self.super_admin? || SETTINGS['grant_admin_privileges'].include?(self.email)
  end
  
  # ### Description
  #
  # Returns the seconds missing to the expiration of the trial account
  #
  # ### Returns
  #
  # An integer
  #
  def trial_to_expiration
    return nil if !self.trial?
    self.created_at.to_i + (SETTINGS['saas_trial_duration'] * 86400) - Time.zone.now.to_i
  end
  
  # ### Description
  #
  # Returns a string representing the percentage of trial expiration
  #
  # ### Returns
  #
  # An integer
  #
  def trial_to_expiration_percentage
    return nil if !self.trial?
    "#{((100.to_f * self.trial_to_expiration.to_f) / (SETTINGS['saas_trial_duration'].to_f * 86400.to_f)).to_s}%"
  end
  
  # ### Description
  #
  # It accepts all the policies declared in +registration_policies+. Example:
  #   User.new.accept_policies
  #
  # ### Returns
  #
  # An enumerator of the policies
  #
  def accept_policies
    registration_policies.each{ |p| send("#{p}=", '1') }
  end
  
  # ### Description
  #
  # Saves the Video Editor cache; if the param is +nil+, the cache is emptied
  #
  # ### Args
  #
  # * *cache*: the cache to be saved (it must be a hash with the structure defined in Media::Video::Editing::Parameters#convert_parameters; if +nil+ it empties the cache)
  #
  def video_editor_cache!(cache = nil)
    update_attribute :metadata, OpenStruct.new(metadata.marshal_dump.merge(video_editor_cache: cache))
    nil
  end
  
  # ### Description
  #
  # Returns the current Video Editor cache for this user
  #
  # ### Returns
  #
  # A hash with parameters (for a sample structure, see Media::Video::Editing::Parameters#convert_parameters)
  #
  def video_editor_cache
    metadata.try(:video_editor_cache)
  end
  
  # ### Description
  #
  # Saves the Audio Editor cache; if the param is +nil+, the cache is emptied
  #
  # ### Args
  #
  # * *cache*: the cache to be saved (it must be a hash with the structure defined in Media::Audio::Editing::Parameters#convert_parameters; if +nil+ it empties the cache)
  #
  def audio_editor_cache!(cache = nil)
    update_attribute :metadata, OpenStruct.new(metadata.marshal_dump.merge(audio_editor_cache: cache))
    nil
  end
  
  # ### Description
  #
  # Returns the current Audio Editor cache for this user
  #
  # ### Returns
  #
  # A hash with parameters (for a sample structure, see Media::Audio::Editing::Parameters#convert_parameters)
  #
  def audio_editor_cache
    metadata.try(:audio_editor_cache)
  end
  
  # ### Description
  #
  # Alternative to the association +mailing_list_groups+, that sorts the groups by name
  #
  # ### Returns
  #
  # An array of objects of kind MailingListGroup
  #
  def own_mailing_list_groups
    MailingListGroup.where(:user_id => self.id).order(:name)
  end
  
  # ### Description
  #
  # True if the user is trial
  #
  # ### Returns
  #
  # Boolean
  #
  def trial?
    return false if self.admin?
    SETTINGS['saas_registration_mode'] && self.purchase_id.nil?
  end
  
  # ### Description
  #
  # Creates a temporary unique new name for a MailingListGroup (used in MailingListController#create_group)
  #
  # ### Returns
  #
  # A string
  #
  def new_mailing_list_name
    I18n.t('users.mailing_list.label', :number => (MailingListGroup.where(:user_id => self.id).count + 1))
  end
  
  # ### Description
  #
  # Manual attr_reader for the constant REGISTRATION_POLICIES, that contains all the policies as configured in settings.yml
  #
  def registration_policies
    REGISTRATION_POLICIES
  end
  
  # ### Description
  #
  # Sets the subjects associated to this user (see UsersSubject)
  #
  def subject_ids=(subject_ids)
    users_subjects.reload.clear
    subject_ids.each { |id| users_subjects.build :user => self, :subject_id => id } if subject_ids
    subject_ids
  end
  
  # ### Description
  #
  # Method used in the front end as a shortcut to show the full name of the user
  #
  # ### Returns
  #
  # A string
  #
  def full_name
    "#{self.name} #{self.surname}"
  end
  
  # ### Description
  #
  # Method used in the front end that returns the name of the first Location attached to the user
  #
  # ### Returns
  #
  # A string
  #
  def base_location
    my_location = self.location
    my_location.nil? ? '-' : my_location.name
  end
  
  # ### Description
  #
  # Used in the front end, it returns a resume of all the parents locations of the user
  #
  # ### Returns
  #
  # A string
  #
  def parent_locations
    resp = ''
    locations = []
    first = true
    current_location = self.location
    return '-' if current_location.nil?
    (0...SETTINGS['location_types'].length).to_a.each do |index|
      if current_location.class.to_s != SETTINGS['location_types'].last
        locations << current_location
      end
      current_location = current_location.parent
    end
    locations.reverse.each do |l|
      if first
        resp = "#{l.name}"
        first = false
      else
        resp = "#{resp} - #{l.name}"
      end
    end
    resp
  end
  
  # ### Description
  #
  # Checks if the Video Editor is available (this is true if there is no Video in conversion at the moment); used in the filters of VideoEditorController
  #
  # ### Returns
  #
  # A boolean
  #
  def video_editor_available
    Video.where(:converted => false, :user_id => id).all?{ |record| record.uploaded? && !record.modified? }
  end
  
  # ### Description
  #
  # Checks if the Audio Editor is available (this is true if there is no Audio in conversion at the moment); used in the filters of AudioEditorController
  #
  # ### Returns
  #
  # A boolean
  #
  def audio_editor_available
    Audio.where(:converted => false, :user_id => id).all?{ |record| record.uploaded? && !record.modified? }
  end
  
  # ### Description
  #
  # Global method used to search for elements (see SearchController#index). Each element has its status set with MediaElement#set_status.
  # * *first*, it checks the correctness of all the parameters received;
  # * *then*, if +word+ is blank, it calls just User#search_media_elements_without_tag, that search using the other parameters inserted by the user
  # * *otherwise*, it checks if the word is a Fixnum (it represents the id of a specific Tag) or a String (it represents a word to be matched against the list of registered tags)
  #   * if +word+ is a Fixnum, the method just calls User#search_media_elements_with_tag, which returns only the elements associated to that particular Tag (of course, filtered by the other parameters)
  #   * if +word+ is a String, the method calls User#search_media_elements_with_tag (that returns the media elements found) and User#get_tags_associated_to_media_element_search (that returns the list of tags associated to the search)
  # * there is also the available option +only_tags+: if this option is used with a +word+ of type String, the method calls only User#get_tags_associated_to_media_element_search (this option is typically used when the user is filtering a previous search by a specific Tag: in this case, calling only the method with +word+ = Fixnum, there would be no way to know the previous list of tags, hence in the controller the method is called again with +word+ = String and with +only_tags+ = true)
  #
  # ### Args
  #
  # * *word*: the search parameter. It can be:
  #   * +blank+ if you need only to search by filters
  #   * +integer+ if you want to filter by a specific tag
  #   * +string+ if you want to match a keyword against the list of tags in the database
  # * *page*: pagination parameter
  # * *for_page*: pagination parameter
  # * *order*: one of the keywords defined in SearchOrders
  # * *filter*: one of the keywords defined in Filters
  # * *only_tags*: optional boolean, if used with a +word+ of kind String returns only the list of tags associated to the search
  #
  # ### Returns
  #
  # A hash with the following keys:
  # * *records*: the effective content of the research, an array of object of type MediaElement
  # * *records_amount*: an integer, the total number of elements found
  # * *pages_amount*: an integer, the total number of pages in the search result
  # * *tags*: if required, an array of objects of type Tag. This is the list of the first 20 tags associated to at least an element in the search result, ordered by numbers of occurrences among the search results (i.e. order of relevance)
  #
  def search_media_elements(word, page, for_page, order=nil, filter=nil, only_tags=nil)
    only_tags = false if only_tags.nil?
    page = 1 if page.class != Fixnum || page <= 0
    for_page = 1 if for_page.class != Fixnum || for_page <= 0
    filter = Filters::ALL_MEDIA_ELEMENTS if filter.nil? || !Filters::MEDIA_ELEMENTS_SEARCH_SET.include?(filter)
    order = SearchOrders::UPDATED_AT if order.nil? || !SearchOrders::MEDIA_ELEMENTS_SET.include?(order)
    offset = (page - 1) * for_page
    if word.blank?
      return search_media_elements_without_tag(offset, for_page, filter, order)
    else
      if word.class != Fixnum
        word = word.to_s
        if only_tags
          return get_tags_associated_to_media_element_search(word, filter)
        else
          resp = search_media_elements_with_tag(word, offset, for_page, filter, order)
          resp[:tags] = get_tags_associated_to_media_element_search(word, filter)
          return resp
        end
      else
        return search_media_elements_with_tag(word, offset, for_page, filter, order)
      end
    end
  end
  
  # ### Description
  #
  # Global method used to search for lessons (see SearchController#index). Each lesson has its status set with Lesson#set_status.
  # * *first*, it checks the correctness of all the parameters received;
  # * *then*, if +word+ is blank, it calls just User#search_lessons_without_tag, that search using the other parameters inserted by the user
  # * *otherwise*, it checks if the word is a Fixnum (it represents the id of a specific Tag) or a String (it represents a word to be matched against the list of registered tags)
  #   * if +word+ is a Fixnum, the method just calls User#search_lessons_with_tag, which returns only the lessons associated to that particular Tag (of course, filtered by the other parameters)
  #   * if +word+ is a String, the method calls User#search_lessons_with_tag (that returns the lessons found) and User#get_tags_associated_to_lesson_search (that returns the list of tags associated to the search)
  # * there is also the available option +only_tags+: if this option is used with a +word+ of type String, the method calls only User#get_tags_associated_to_lesson_search (this option is typically used when the user is filtering a previous search by a specific Tag: in this case, calling only the method with +word+ = Fixnum, there would be no way to know the previous list of tags, hence in the controller the method is called again with +word+ = String and with +only_tags+ = true)
  #
  # ### Args
  #
  # * *word*: the search parameter. It can be:
  #   * +blank+ if you need only to search by filters
  #   * +integer+ if you want to filter by a specific tag
  #   * +string+ if you want to match a keyword against the list of tags in the database
  # * *page*: pagination parameter
  # * *for_page*: pagination parameter
  # * *order*: one of the keywords defined in SearchOrders
  # * *filter*: one of the keywords defined in Filters
  # * *subject_id*: the id of a Subject, this extends the filter to lessons associated to that subject
  # * *school_level_id*: the school level of the lesson
  # * *only_tags*: optional boolean, if used with a +word+ of kind String returns only the list of tags associated to the search
  #
  # ### Returns
  #
  # A hash with the following keys:
  # * *records*: the effective content of the research, an array of object of type Lesson
  # * *records_amount*: an integer, the total number of lessons found
  # * *pages_amount*: an integer, the total number of pages in the search result
  # * *tags*: if required, an array of objects of type Tag. This is the list of the first 20 tags associated to at least a lesson in the search result, ordered by numbers of occurrences among the search results (i.e. order of relevance)
  #
  def search_lessons(word, page, for_page, order=nil, filter=nil, subject_id=nil, only_tags=nil, school_level_id=nil)
    only_tags = false if only_tags.nil?
    page = 1 if page.class != Fixnum || page <= 0
    for_page = 1 if for_page.class != Fixnum || for_page <= 0
    subject_id = nil if ![NilClass, Fixnum].include?(subject_id.class)
    school_level_id = nil if ![NilClass, Fixnum].include?(school_level_id.class)
    filter = Filters::ALL_LESSONS if filter.nil? || !Filters::LESSONS_SEARCH_SET.include?(filter)
    order = SearchOrders::UPDATED_AT if order.nil? || !SearchOrders::LESSONS_SET.include?(order)
    offset = (page - 1) * for_page
    if word.blank?
      return search_lessons_without_tag(offset, for_page, filter, subject_id, order, school_level_id)
    else
      if word.class != Fixnum
        word = word.to_s
        if only_tags
          return get_tags_associated_to_lesson_search(word, filter, subject_id, school_level_id)
        else
          resp = search_lessons_with_tag(word, offset, for_page, filter, subject_id, order, school_level_id)
          resp[:tags] = get_tags_associated_to_lesson_search(word, filter, subject_id, school_level_id)
          return resp
        end
      else
        return search_lessons_with_tag(word, offset, for_page, filter, subject_id, order, school_level_id)
      end
    end
  end
  
  # ### Description
  #
  # Sends a Report for a Lesson
  #
  # ### Args
  #
  # * *lesson_id*: id of the lesson to be reported
  # * *msg*: the attached message
  #
  # ### Returns
  #
  # A boolean
  #
  def report_lesson(lesson_id, msg)
    errors.clear
    if self.new_record?
      errors.add(:base, :problem_reporting)
      return false
    end
    r = Report.new
    r.user_id = self.id
    r.reportable_type = 'Lesson'
    r.reportable_id = lesson_id
    r.comment = msg
    if !r.save
      if r.errors.added? :reportable_id, :taken
        errors.add(:base, :lesson_already_reported)
      else
        errors.add(:base, :problem_reporting)
      end
      return false
    end
    true
  end
  
  # ### Description
  #
  # Sends a Report for a MediaElement
  #
  # ### Args
  #
  # * *media_element_id*: id of the element to be reported
  # * *msg*: the attached message
  #
  # ### Returns
  #
  # A boolean
  #
  def report_media_element(media_element_id, msg)
    errors.clear
    if self.new_record?
      errors.add(:base, :problem_reporting)
      return false
    end
    r = Report.new
    r.user_id = self.id
    r.reportable_type = 'MediaElement'
    r.reportable_id = media_element_id
    r.comment = msg
    if !r.save
      if r.errors.added? :reportable_id, :taken
        errors.add(:base, :media_element_already_reported)
      else
        errors.add(:base, :problem_reporting)
      end
      return false
    end
    true
  end
  
  # ### Description
  #
  # Saves a 'I like you' for a Lesson
  #
  # ### Args
  #
  # * *lesson_id*: the id of the lesson that the user appreciates
  #
  # ### Returns
  #
  # A boolean
  #
  def like(lesson_id)
    return false if self.new_record? || !Lesson.exists?(lesson_id)
    return true if Like.where(:lesson_id => lesson_id, :user_id => self.id).any?
    l = Like.new
    l.user_id = self.id
    l.lesson_id = lesson_id
    return l.save
  end
  
  # ### Description
  #
  # Removes a 'I like you' that the user had formerly assigned to a Lesson
  #
  # ### Args
  #
  # * *lesson_id*: the id of the lesson tha the user doesn't appreciate anymore
  #
  # ### Returns
  #
  # A boolean
  #
  def dislike(lesson_id)
    return false if self.new_record? || !Lesson.exists?(lesson_id)
    like = Like.where(:lesson_id => lesson_id, :user_id => self.id).first
    return true if like.nil?
    like.destroy
    return Like.where(:lesson_id => lesson_id, :user_id => self.id).empty?
  end
  
  # ### Description
  #
  # Extracts the elements present in the user's personal section (see MediaElementsController#index, and GalleriesController): the method uses the scope +of+ defined in MediaElement, and applies filters on it. Each element has its status set with MediaElement#set_status.
  #
  # ### Args
  #
  # * *page*: pagination parameter
  # * *per_page*: pagination parameter
  # * *filter*: an additional filter defined in Filters
  #
  # ### Returns
  #
  # A hash with the following keys:
  # * *records*: the effective content of the research, an array of object of type MediaElement
  # * *pages_amount*: an integer, the total number of pages in the method's result
  #
  def own_media_elements(page, per_page, filter=Filters::ALL_MEDIA_ELEMENTS, from_gallery=false)
    page = 1 if !page.is_a?(Fixnum) || page <= 0
    for_page = 1 if !for_page.is_a?(Fixnum) || for_page <= 0
    offset = (page - 1) * per_page
    select = 'media_elements.*'
    select = "#{select}, (SELECT COUNT (*) FROM bookmarks WHERE bookmarks.bookmarkable_type = #{self.class.connection.quote 'MediaElement'} AND bookmarks.bookmarkable_id = media_elements.id AND bookmarks.user_id = #{self.class.connection.quote self.id.to_i}) AS bookmarks_count, (SELECT COUNT(*) FROM media_elements_slides WHERE (media_elements_slides.media_element_id = media_elements.id)) AS instances" if !from_gallery
    relation = MediaElement.select(select).of(self)
    if [Filters::VIDEO, Filters::AUDIO, Filters::IMAGE].include? filter
      relation = relation.where('sti_type = ?', filter.capitalize)
    end
    pages_amount = Rational(relation.count, per_page).ceil
    resp = []
    if from_gallery
      resp = relation.limit(per_page).offset(offset)
    else
      relation.limit(per_page).offset(offset).each do |me|
        me.set_status self.id, {:bookmarked => :bookmarks_count}
        resp << me
      end
    end
    {:records => resp, :pages_amount => pages_amount}
  end
  
  # ### Description
  #
  # Extracts the lessons present in the user's personal section (see LessonsController#index): the method uses the scope +of+ defined in Lesson, and applies filters on it. Each lesson has its status set with Lesson#set_status.
  #
  # ### Args
  #
  # * *page*: pagination parameter
  # * *per_page*: pagination parameter
  # * *filter*: an additional filter defined in Filters
  #
  # ### Returns
  #
  # A hash with the following keys:
  # * *records*: the effective content of the research, an array of object of type Lesson
  # * *pages_amount*: an integer, the total number of pages in the method's result
  #
  def own_lessons(page, per_page, filter=Filters::ALL_LESSONS, from_virtual_classroom=false)
    page = 1 if !page.is_a?(Fixnum) || page <= 0
    for_page = 1 if !for_page.is_a?(Fixnum) || for_page <= 0
    offset = (page - 1) * per_page
    relation1 = nil
    if from_virtual_classroom
      relation1 = Lesson.preload(:subject, :user).select("lessons.*,
        (SELECT COUNT (*) FROM virtual_classroom_lessons WHERE virtual_classroom_lessons.lesson_id = lessons.id AND virtual_classroom_lessons.user_id = #{self.class.connection.quote self.id.to_i}) AS virtuals_count
      ")
    else
      relation1 = Lesson.preload(:subject, :user, :school_level, {:user => :location}).select("
        lessons.*,
        (SELECT COUNT (*) FROM bookmarks WHERE bookmarks.bookmarkable_type = #{self.class.connection.quote 'Lesson'} AND bookmarks.bookmarkable_id = lessons.id AND bookmarks.user_id = #{self.class.connection.quote self.id.to_i}) AS bookmarks_count,
        (SELECT COUNT (*) FROM bookmarks WHERE bookmarks.bookmarkable_type = #{self.class.connection.quote 'Lesson'} AND bookmarks.bookmarkable_id = lessons.id) AS all_bookmarks_count,
        (SELECT COUNT (*) FROM bookmarks WHERE bookmarks.bookmarkable_type = #{self.class.connection.quote 'Lesson'} AND bookmarks.bookmarkable_id = lessons.id AND bookmarks.user_id != #{self.class.connection.quote self.id} AND bookmarks.created_at < lessons.updated_at) AS notification_bookmarks,
        (SELECT COUNT (*) FROM virtual_classroom_lessons WHERE virtual_classroom_lessons.lesson_id = lessons.id AND virtual_classroom_lessons.user_id = #{self.class.connection.quote self.id.to_i}) AS virtuals_count,
        (SELECT COUNT (*) FROM likes WHERE likes.lesson_id = lessons.id AND likes.user_id = #{self.class.connection.quote self.id.to_i}) AS likes_count,
        (SELECT COUNT (*) FROM likes WHERE likes.lesson_id = lessons.id) AS likes_general_count
      ")
    end
    relation2 = nil
    case filter
      when Filters::PRIVATE
        relation1 = relation1.where(user_id: self.id, is_public: false).order('updated_at DESC')
        relation2 = Lesson.where(user_id: self.id, is_public: false).order('updated_at DESC')
      when Filters::PUBLIC
        relation1 = relation1.of(self).where(is_public: true)
        relation2 = Lesson.of(self).where(is_public: true)
      when Filters::LINKED
        relation1 = relation1.joins(:bookmarks).where(bookmarks: { user_id: self.id }).order('bookmarks.created_at DESC')
        relation2 = Lesson.joins(:bookmarks).where(bookmarks: { user_id: self.id }).order('bookmarks.created_at DESC')
      when Filters::ONLY_MINE
        relation1 = relation1.where(user_id: self.id).order('updated_at DESC')
        relation2 = Lesson.where(user_id: self.id).order('updated_at DESC')
      when Filters::COPIED
        relation1 = relation1.where(:user_id => self.id, :copied_not_modified => true).order('updated_at DESC')
        relation2 = Lesson.where(:user_id => self.id, :copied_not_modified => true).order('updated_at DESC')
      when Filters::ALL_LESSONS
        relation1 = relation1.of(self)
        relation2 = Lesson.of(self)
      else
        raise ArgumentError, 'filter not supported'
    end
    pages_amount = Rational(relation2.count, per_page).ceil
    relation1 = relation1.limit(per_page).offset(offset)
    relation2 = relation2.limit(per_page).offset(offset)
    covers = {}
    Slide.where(:lesson_id => relation2.pluck(:id), :kind => 'cover').preload(:media_elements_slides, {:media_elements_slides => :media_element}).each do |cov|
      covers[cov.lesson_id] = cov
    end
    if from_virtual_classroom
      resp = relation1
    else
      resp = []
      relation1.each do |lesson|
        lesson.set_status self.id, {:bookmarked => :bookmarks_count, :in_vc => :virtuals_count, :liked => :likes_count}
        resp << lesson
      end
    end
    {:records => resp, :pages_amount => pages_amount, :covers => covers}
  end
  
  # ### Description
  #
  # Extracts the documents present in the user's personal section (see DocumentsController#index).
  #
  # ### Args
  #
  # * *page*: pagination parameter
  # * *per_page*: pagination parameter
  # * *order_by*: order, from SearchOrders
  # * *word*: keyword, if any
  #
  # ### Returns
  #
  # A hash with the following keys:
  # * *records*: the effective content of the research, an array of object of type Document
  # * *pages_amount*: an integer, the total number of pages in the method's result
  #
  def own_documents(page, per_page, order_by=SearchOrders::CREATED_AT, word=nil, from_gallery=false)
    page = 1 if !page.is_a?(Fixnum) || page <= 0
    for_page = 1 if !for_page.is_a?(Fixnum) || for_page <= 0
    offset = (page - 1) * per_page
    word = word.to_s if !word.nil?
    order = ''
    case order_by
      when SearchOrders::CREATED_AT
        order = 'created_at DESC'
      when SearchOrders::TITLE
        order = 'title ASC, created_at DESC'
    end
    select = 'documents.*'
    select = "#{select}, (SELECT COUNT(*) FROM documents_slides INNER JOIN slides ON slides.id = documents_slides.slide_id INNER JOIN lessons ON lessons.id = slides.lesson_id WHERE documents_slides.document_id = documents.id AND lessons.user_id = documents.user_id) AS instances" if !from_gallery
    relation = Document.select(select)
    if word.nil?
      relation = relation.where(:user_id => self.id).order(order)
    else
      relation = relation.where('user_id = ? AND title ILIKE ?', self.id, "%#{word}%").order(order)
    end
    {
      :records => relation.limit(per_page).offset(offset),
      :pages_amount => Rational(relation.count, per_page).ceil
    }
  end
  
  # ### Description
  #
  # Returns the first n suggested lessons (lessons which are public, not owned nor linked by the user, with a subject in common with him, ordered by date of last modification). Each lesson has its status set with Lesson#set_status. Used in DashboardController#index.
  #
  # ### Args
  #
  # * *n*: the number of requested suggested lessons
  #
  # ### Returns
  #
  # An array of objects of type Lesson
  #
  def suggested_lessons(n)
    n = 1 if n.class != Fixnum || n < 0
    subject_ids = []
    UsersSubject.where(:user_id => self.id).each do |us|
      subject_ids << us.subject_id
    end
    resp = Lesson.preload(:subject, :user).select("lessons.*, 0 AS bookmarks_count, 0 AS virtuals_count, (SELECT COUNT (*) FROM likes WHERE likes.lesson_id = lessons.id AND likes.user_id = #{self.class.connection.quote self.id.to_i}) AS likes_count").where('is_public = ? AND user_id != ? AND subject_id IN (?) AND NOT EXISTS (SELECT * FROM bookmarks WHERE bookmarks.bookmarkable_type = ? AND bookmarks.bookmarkable_id = lessons.id AND bookmarks.user_id = ?)', true, self.id, subject_ids, 'Lesson', self.id).order('updated_at DESC').limit(n)
    ids = []
    resp.each do |l|
      ids << l.id
      l.set_status self.id, {:bookmarked => :bookmarks_count, :in_vc => :virtuals_count, :liked => :likes_count}
    end
    covers = {}
    Slide.where(:lesson_id => ids, :kind => 'cover').preload(:media_elements_slides, {:media_elements_slides => :media_element}).each do |cov|
      covers[cov.lesson_id] = cov
    end
    {:records => resp, :covers => covers}
  end
  
  # ### Description
  #
  # Returns the first n suggested elements (elements which are public, not owned nor linked by the user, ordered by date of publication). Each element has its status set with MediaElement#set_status. Used in DashboardController#index.
  #
  # ### Args
  #
  # * *n*: the number of requested suggested elements
  #
  # ### Returns
  #
  # An array of objects of type MediaElement
  #
  def suggested_media_elements(n)
    n = 1 if n.class != Fixnum || n < 0
    resp = MediaElement.select('media_elements.*, 0 AS bookmarks_count').where('is_public = ? AND user_id != ? AND NOT EXISTS (SELECT * FROM bookmarks WHERE bookmarks.bookmarkable_type = ? AND bookmarks.bookmarkable_id = media_elements.id AND bookmarks.user_id = ?)', true, self.id, 'MediaElement', self.id).order('publication_date DESC').limit(n)
    resp.each do |me|
      me.set_status self.id, {:bookmarked => :bookmarks_count}
    end
    resp
  end
  
  # ### Description
  #
  # Used to create a Bookmark on a lesson or a media element
  #
  # ### Args
  #
  # * *type*: 'Lesson' or 'MediaElement'
  # * *target_id*: the id of the lesson or element to bookmark
  #
  # ### Returns
  #
  # A boolean
  #
  def bookmark(type, target_id)
    return false if self.new_record?
    b = Bookmark.new
    b.bookmarkable_type = type
    b.user_id = self.id
    b.bookmarkable_id = target_id
    b.save
  end
  
  # ### Description
  #
  # Deletes all the elements of type VirtualClassroomLesson associated to the user. Used in VirtualClassroomController#empty_virtual_classroom
  #
  def empty_virtual_classroom
    VirtualClassroomLesson.where(:user_id => self.id).each do |vcl|
      vcl.destroy
    end
  end
  
  # ### Description
  #
  # Sets +position+ = +nil+ for all the elements of type VirtualClassroomLesson associated to the user (hence, it removes them from the playlist). Used in VirtualClassroomController#empty_playlist
  #
  # ### Returns
  #
  # A boolean
  #
  def empty_playlist
    return false if self.new_record?
    resp = false
    ActiveRecord::Base.transaction do
      VirtualClassroomLesson.where('user_id = ? AND position IS NOT NULL', self.id).order('position DESC').each do |vcl|
        vcl.position = nil
        raise ActiveRecord::Rollback if !vcl.save
      end
      resp = true
    end
    resp
  end
  
  # ### Description
  #
  # Returns the list of lessons in the user's Virtual Classroom (used in VirtualClassroomController#index)
  #
  # ### Args
  #
  # * *page*: pagination parameter
  # * *per_page*: pagination parameter
  #
  # ### Returns
  #
  # A hash with the following keys:
  # * *records*: the effective content of the research, an array of object of type VirtualClassroomLesson
  # * *pages_amount*: an integer, the total number of pages in the method's result
  #
  def full_virtual_classroom(page, per_page)
    page = 1 if !page.is_a?(Fixnum) || page <= 0
    for_page = 1 if !for_page.is_a?(Fixnum) || for_page <= 0
    offset = (page - 1) * per_page
    resp = {}
    resp[:pages_amount] = Rational(VirtualClassroomLesson.where(:user_id => self.id).count, per_page).ceil
    resp[:records] = VirtualClassroomLesson.preload(:lesson, {:lesson => :user}, {:lesson => :subject}).where(:user_id => self.id).order('created_at DESC').offset(offset).limit(per_page)
    resp[:covers] = {}
    Slide.where(:lesson_id => resp[:records].pluck(:lesson_id), :kind => 'cover').preload(:media_elements_slides, {:media_elements_slides => :media_element}).each do |cov|
      resp[:covers][cov.lesson_id] = cov
    end
    return resp
  end
  
  # ### Description
  #
  # Gets the total number of notifications associated to the user (used in ApplicationController#initialize_layout and NotificationsController#destroy)
  #
  # ### Returns
  #
  # An integer
  #
  def tot_notifications_number
    Notification.where(:user_id => self.id).count
  end
  
  # ### Description
  #
  # Destroys a Notification and reloads the current block of notifications (used in NotificationsController#destroy)
  #
  # ### Args
  #
  # * *notification_id*: the id of the notification to be deleted
  # * *offset*: the current offset of the notification block that the user is visualizing
  #
  # ### Returns
  #
  # A boolean
  #
  def destroy_notification_and_reload(notification_id, offset)
    notification_id = 0 if !notification_id.is_a?(Fixnum) || notification_id < 0
    offset = 0 if !offset.is_a?(Fixnum) || offset < 0
    resp = nil
    ActiveRecord::Base.transaction do
      n = Notification.find_by_id(notification_id)
      raise ActiveRecord::Rollback if n.nil? || n.user_id != self.id
      n.destroy
      resp_last = Notification.order('created_at DESC').where(:user_id => self.id).limit(offset).last
      resp_offset = Notification.where(:user_id => self.id).limit(offset).count
      resp_last = nil if ([resp_offset, resp_offset] != [SETTINGS['notifications_loaded_together'], offset])
      resp = {:last => resp_last, :offset => resp_offset}
    end
    resp
  end
  
  # ### Description
  #
  # Gets the first visible block of notifications associated to the user (used in ApplicationController#initialize_layout and NotificationsController#get_new_block)
  #
  # ### Returns
  #
  # An array of objects of type Notification
  #
  def notifications_visible_block(offset, limit)
    Notification.order('created_at DESC').where(:user_id => self.id).offset(offset).limit(limit)
  end
  
  # ### Description
  #
  # Gets the total number of notifications not seen by the user (used in ApplicationController#initialize_layout and NotificationsController#seen)
  #
  # ### Returns
  #
  # An integer
  #
  def number_notifications_not_seen
    Notification.where(:seen => false, :user_id => self.id).count
  end
  
  # ### Description
  #
  # Checks if the playlist is full in the user's Virtual Classroom
  #
  # ### Returns
  #
  # A boolean
  #
  def playlist_full?
    VirtualClassroomLesson.where('user_id = ? AND position IS NOT NULL', self.id).count == SETTINGS['lessons_in_playlist']
  end
  
  # ### Description
  #
  # Returns the playlist of the user's Virtual Classroom
  #
  # ### Args
  #
  # * *from_viewer*: true if the method needs to preload users together with the lesson
  #
  # ### Returns
  #
  # An array of objects of type VirtualClassroomLesson
  #
  def playlist(from_viewer=false)
    resp = from_viewer ? VirtualClassroomLesson.preload(:lesson, {:lesson => :subject}, {:lesson => :user}) : VirtualClassroomLesson.preload(:lesson, {:lesson => :subject})
    resp.where('user_id = ? AND position IS NOT NULL', self.id).order(:position)
  end
  
  # ### Description
  #
  # Gets the playlist for the Lesson Viewer (used in LessonViewerController#playlist)
  #
  # ### Returns
  #
  # An array of ordered objects of type Slide (they correspond to the slides of the lessons in the playlist)
  #
  def playlist_for_viewer
    Slide.preload(:documents_slides, {:documents_slides => :document}, :lesson, {:lesson => :user}, {:lesson => :subject}, :media_elements_slides, {:media_elements_slides => :media_element}).joins(:lesson, {:lesson => :virtual_classroom_lessons}).where('virtual_classroom_lessons.user_id = ? AND virtual_classroom_lessons.lesson_id = lessons.id AND virtual_classroom_lessons.position IS NOT NULL', self.id).order('virtual_classroom_lessons.position ASC, slides.position ASC')
  end
  
  # ### Description
  #
  # Creates a lesson belonging to the user (used in LessonEditorController#create)
  #
  # ### Args
  #
  # * *title*: the title
  # * *description*: the description
  # * *subject_id*: the id of the Subject associated to the Lesson, chosen among the ones associated to the user at the moment of the creation
  # * *tags*: tags (in the shape 'tag1, tag2, tag3, tag4')
  #
  # ### Returns
  #
  # If the lesson was correctly created, it returns a new object of type Lesson; otherwise, its errors.
  #
  def create_lesson(title, description, subject_id, tags)
    return nil if self.new_record?
    if UsersSubject.where(:user_id => self.id, :subject_id => subject_id).empty?
      lesson = Lesson.new :subject_id => subject_id, :school_level_id => self.school_level_id, :title => title, :description => description
      lesson.copied_not_modified = false
      lesson.user_id = self.id
      lesson.tags = tags
      lesson.save_tags = true
      lesson.valid?
      lesson.errors.add(:subject_id, :is_not_your_subject)
      return lesson.errors
    end
    lesson = Lesson.new :subject_id => subject_id, :school_level_id => self.school_level_id, :title => title, :description => description
    lesson.copied_not_modified = false
    lesson.user_id = self.id
    lesson.tags = tags
    lesson.save_tags = true
    return lesson.save ? lesson : lesson.errors
  end
  
  # ### Description
  #
  # Checks if the user is super admin or not (used in User#admin? and User#destroy_with_dependencies)
  #
  # ### Returns
  #
  # A boolean
  #
  def super_admin?
    super_admin = User.admin
    !super_admin.nil? && self.id == super_admin.id
  end
  
  # ### Description
  #
  # Used to destroy a user and remove it from the database: since for safety reasons there are no database cascade destructions for the associated relations Lesson, UsersSubject, Bookmark, Notification, Like and Report, these are destroyed manually here; for the table MailingListGroup, there is a cascade destruction; for the table MediaElement, the method destroys only the private ones and changes the owner of the public ones (assigned to the super administrator, extracted by the method User.admin). The only user that can't be destroyed with this method is the super administrator (the method checks this using User#super_admin?)
  #
  # ### Returns
  #
  # A boolean
  #
  def destroy_with_dependencies
    if self.new_record? || self.super_admin?
      errors.add(:base, :problem_destroying)
      return false
    end
    resp = false
    ActiveRecord::Base.transaction do
      begin
        Lesson.where(:user_id => self.id).each do |l|
          if !l.destroy_with_notifications
            errors.add(:base, :problem_destroying)
            raise ActiveRecord::Rollback
          end
        end
        UsersSubject.where(:user_id => self.id).each do |us|
          us.destroy
        end
        Document.where(:user_id => self.id).each do |d|
          d.destroy
        end
        MediaElement.where(:user_id => self.id).each do |me|
          if me.is_public
            me.user_id = User.admin.id
            if !me.save
              errors.add(:base, :problem_destroying)
              raise ActiveRecord::Rollback
            end
          else
            me.destroy
          end
        end
        Bookmark.where(:user_id => self.id).each do |b|
          b.destroy
        end
        Notification.where(:user_id => self.id).each do |n|
          n.destroy
        end
        Like.where(:user_id => self.id).each do |l|
          l.destroy
        end
        Report.where(:user_id => self.id).each do |r|
          r.destroy
        end
        self.destroy
      rescue ActiveRecord::InvalidForeignKey
        errors.add(:base, :problem_destroying)
        raise ActiveRecord::Rollback
      end
      resp = true
    end
    resp
  end
  
  # ### Description
  #
  # Used in the autocomplete, in the section of the administrator where it's possible to send a notification to multiple users (Admin::MessagesController#filter_users)
  #
  # ### Args
  #
  # * *term*: the string to be matched agains +email+, +name+ and +surname+
  #
  # ### Returns
  #
  # A list of query results where the only field selected is the full name (+name+ + ' ' + +surname+)
  #
  def self.get_full_names(term)
    where('email ILIKE ? OR name ILIKE ? OR surname ILIKE ?', "%#{term}%", "%#{term}%", "%#{term}%").select("id, name || ' ' || surname AS value")
  end
  
  # ### Description
  #
  # Removes a file from the list of multiple uploading of an element (used in Admin::MediaElementsController#quick_upload_delete and Admin::MediaElementsController#create).
  #
  # ### Args
  #
  # * *name*: the random key generated in User#save_in_admin_quick_uploading_cache, used as a key in the hash of files in uploading
  #
  # ### Returns
  #
  # A boolean
  #
  def remove_from_admin_quick_uploading_cache(name)
    return false if !File.exists?(Rails.root.join("public/admin/#{self.id}/map.yml"))
    map = YAML::load(File.open(Rails.root.join("public/admin/#{self.id}/map.yml")))
    item = map[name]
    return false if item.nil?
    FileUtils.rm Rails.root.join("public/admin/#{self.id}/#{name}#{item[:ext]}")
    map.delete name
    map[:index].delete name
    yaml = File.open(Rails.root.join("public/admin/#{self.id}/map.yml"), 'w')
    yaml.write map.to_yaml
    yaml.close
    true
  end
  
  # ### Description
  #
  # Saves a file in the uploading cache (used in Admin::MediaElementsController#quick_upload): the method creates a random name for the file, that will be used as its unique key in the hash
  #
  # ### Args
  #
  # * *file*: the attached file
  # * *title*: the title (if +nil+, it doesn't specify any title and it'll need to be inserted at the time of the creation)
  # * *description*: the description (if +nil+, it doesn't specify any description and it'll need to be inserted at the time of the creation)
  # * *tags*: the tags in shape 'tag1, tag2, tag3, tag4' (if +nil+, it doesn't specify any tags and tags will need to be inserted at the time of the creation)
  #
  # ### Returns
  #
  # A hash with the following keys
  # * *name*: the randomly extracted key
  # * *ext*: the extension extracted through MediaElement.new_with_sti_type_inferring
  # * *type*: the type in ['audio', 'image', 'video']
  # * *title*: the title
  # * *description*: the description
  # * *tags*: the tags in shape 'tag1, tag2, tag3, tag4'
  # * *original_name*: the original name with which the file was uploaded
  #
  def save_in_admin_quick_uploading_cache(file, title=nil, description=nil, tags=nil)
    filetype = MediaElement.filetype(file.original_filename)
    return nil if filetype.nil?
    FileUtils.mkdir Rails.root.join('public/admin') if !File.exists?(Rails.root.join('public/admin'))
    FileUtils.mkdir Rails.root.join("public/admin/#{self.id}") if !File.exists?(Rails.root.join("public/admin/#{self.id}"))
    extension = File.extname file.original_filename
    map = {}
    if File.exists?(Rails.root.join("public/admin/#{self.id}/map.yml"))
      map = YAML::load(File.open(Rails.root.join("public/admin/#{self.id}/map.yml")))
    else
      FileUtils.rm_r Rails.root.join("public/admin/#{self.id}")
      FileUtils.mkdir Rails.root.join("public/admin/#{self.id}")
    end
    name = "a#{SecureRandom.urlsafe_base64(15)}"
    while map.has_key? :"#{name}"
      name = "a#{SecureRandom.urlsafe_base64(15)}"
    end
    if map.has_key? :index
      map[:index].unshift :"#{name}"
    else
      map[:index] = [:"#{name}"]
    end
    map[:"#{name}"] = {:ext => extension, :type => filetype}
    map[:"#{name}"][:original_name] = file.original_filename
    map[:"#{name}"][:title] = title
    map[:"#{name}"][:description] = description
    map[:"#{name}"][:tags] = tags
    yaml = File.open(Rails.root.join("public/admin/#{self.id}/map.yml"), 'w')
    yaml.write map.to_yaml
    yaml.close
    FileUtils.mv file.tempfile.path, Rails.root.join("public/admin/#{self.id}/#{name}#{extension}")
    {
      :name => :"#{name}",
      :ext => extension,
      :type => filetype,
      :title => title,
      :description => description,
      :tags => tags,
      :original_name => file.original_filename
    }
  end
  
  # ### Description
  #
  # Extracts the quick uploadin cache (used in Admin::MediaElementsController#new)
  #
  # ### Returns
  #
  # A hash with the same keys as User#save_in_admin_quick_uploading_cache
  #
  def admin_quick_uploading_cache
    return [] if !File.exists?(Rails.root.join("public/admin/#{self.id}/map.yml"))
    map = YAML::load File.open(Rails.root.join("public/admin/#{self.id}/map.yml"))
    index = map[:index]
    return [] if index.nil? || index.empty?
    resp = []
    index.each do |i|
      map[i][:name] = i
      resp << map[i]
    end
    resp
  end
  
  private
  
  # Submethod of User#search_lessons. It returns the first +n+ tags associated to the result of the research, ordered by number of occurrences of these tags among the results; if the +word+ corresponds to a tag, this tag is put in the first place of the result even if it wouldn't be first according to the normal ordering.
  def get_tags_associated_to_lesson_search(word, filter, subject_id, school_level_id)
    limit = SETTINGS['tags_limit_in_search_engine']
    params = ["#{word}%"]
    joins = "INNER JOIN tags ON (tags.id = taggings.tag_id) INNER JOIN lessons ON (taggings.taggable_type = 'Lesson' AND taggings.taggable_id = lessons.id)"
    where = 'tags.word LIKE ?'
    if !subject_id.nil?
      where = "#{where} AND lessons.subject_id = ?"
      params << subject_id
    end
    if !school_level_id.nil?
      where = "#{where} AND lessons.school_level_id = ?"
      params << school_level_id
    end
    case filter
      when Filters::ALL_LESSONS
        where = "#{where} AND (lessons.is_public = ? OR lessons.user_id = ?)"
        params << true
        params << self.id
      when Filters::PUBLIC
        where = "#{where} AND lessons.is_public = ?"
        params << true
      when Filters::ONLY_MINE
        where = "#{where} AND lessons.user_id = ?"
        params << self.id
      when Filters::NOT_MINE
        where = "#{where} AND lessons.is_public = ? AND lessons.user_id != ?"
        params << true
        params << self.id
    end
    select = 'tags.*, COUNT(*) AS tags_count'
    where_for_current_tag = where.gsub('tags.word LIKE ?', 'tags.word = ?')
    where = "tags.word != ? AND #{where}"
    resp = []
    if Tagging.joins(joins).where(where_for_current_tag, word, *params[1, params.length]).limit(1).present?
      limit -= 1
      resp << Tag.find_by_word(word)
    end
    resp + Tagging.group('tags.id').select(select).joins(joins).where(where, word, *params).order('tags_count DESC, tags.word ASC').limit(limit)
  end
  
  # Submethod of User#search_media_elements. It returns the first +n+ tags associated to the result of the research, ordered by number of occurrences of these tags among the results; if the +word+ corresponds to a tag, this tag is put in the first place of the result even if it wouldn't be first according to the normal ordering.
  def get_tags_associated_to_media_element_search(word, filter)
    limit = SETTINGS['tags_limit_in_search_engine']
    resp = []
    where = 'tags.word != ? AND tags.word LIKE ? AND (media_elements.is_public = ? OR media_elements.user_id = ?)'
    where_for_current_tag = 'tags.word = ? AND (media_elements.is_public = ? OR media_elements.user_id = ?)'
    joins = "INNER JOIN tags ON (tags.id = taggings.tag_id) INNER JOIN media_elements ON (taggings.taggable_type = 'MediaElement' AND taggings.taggable_id = media_elements.id)"
    select = 'tags.*, COUNT(*) AS tags_count'
    case filter
      when Filters::VIDEO
        where = "#{where} AND media_elements.sti_type = 'Video'"
        where_for_current_tag = "#{where_for_current_tag} AND media_elements.sti_type = 'Video'"
      when Filters::AUDIO
        where = "#{where} AND media_elements.sti_type = 'Audio'"
        where_for_current_tag = "#{where_for_current_tag} AND media_elements.sti_type = 'Audio'"
      when Filters::IMAGE
        where = "#{where} AND media_elements.sti_type = 'Image'"
        where_for_current_tag = "#{where_for_current_tag} AND media_elements.sti_type = 'Image'"
    end
    if Tagging.joins(joins).where(where_for_current_tag, word, true, self.id).limit(1).present?
      resp << Tag.find_by_word(word)
      limit -= 1
    end
    resp + Tagging.group('tags.id').select(select).joins(joins).where(where, word, "#{word}%", true, self.id).order('tags_count DESC, tags.word ASC').limit(limit)
  end
  
  # Submethod of User.search_media_elements: if +word+ is a Fixnum, it extracts all the elements associated to that word, otherwise it extracts all the elements whose tags match the +word+. Results are filtered by the +filter+ (chosen among the ones in Filters), and ordered by +order_by+ (chosen among SearchOrders)
  def search_media_elements_with_tag(word, offset, limit, filter, order_by)
    resp = {}
    params = ["#{word}%", true, self.id]
    joins = "INNER JOIN tags ON (tags.id = taggings.tag_id) INNER JOIN media_elements ON (taggings.taggable_type = 'MediaElement' AND taggings.taggable_id = media_elements.id)"
    where = 'tags.word LIKE ? AND (media_elements.is_public = ? OR media_elements.user_id = ?)'
    if word.class == Fixnum
      params = [word, true, self.id]
      joins = "INNER JOIN media_elements ON (taggings.taggable_type = 'MediaElement' AND taggings.taggable_id = media_elements.id)"
      where = 'taggings.tag_id = ? AND (media_elements.is_public = ? OR media_elements.user_id = ?)'
    end
    order = ''
    case order_by
      when SearchOrders::UPDATED_AT
        order = 'media_elements.updated_at DESC'
      when SearchOrders::TITLE
        order = 'media_elements.title ASC, media_elements.updated_at DESC'
    end
    case filter
      when Filters::VIDEO
        where = "#{where} AND media_elements.sti_type = 'Video'"
      when Filters::AUDIO
        where = "#{where} AND media_elements.sti_type = 'Audio'"
      when Filters::IMAGE
        where = "#{where} AND media_elements.sti_type = 'Image'"
    end
    resp[:records] = []
    ids = Tagging.group('media_elements.id').joins(joins).where(where, params[0], params[1], params[2]).order(order).offset(offset).limit(limit).pluck('media_elements.id')
    MediaElement.select( "media_elements.*, (SELECT COUNT (*) FROM bookmarks WHERE bookmarks.bookmarkable_type = #{self.class.connection.quote 'MediaElement'} AND bookmarks.bookmarkable_id = media_elements.id AND bookmarks.user_id = #{self.class.connection.quote self.id.to_i}) AS bookmarks_count, (SELECT COUNT(*) FROM media_elements_slides WHERE (media_elements_slides.media_element_id = media_elements.id)) AS instances").where(:id => ids).order(order).each do |media_element|
      media_element.set_status self.id, {:bookmarked => :bookmarks_count}
      resp[:records] << media_element
    end
    resp[:records_amount] = Tagging.group('media_elements.id').joins(joins).where(where, params[0], params[1], params[2]).count.length
    resp[:pages_amount] = Rational(resp[:records_amount], limit).ceil
    return resp
  end
  
  # Submethod of User#search_media_elements. It returns all the elements in the database, filtered by +filter+ (chosen among the ones in Filters), and ordered by +order_by+ (chosen among the ones in SearchOrders)
  def search_media_elements_without_tag(offset, limit, filter, order_by)
    select = "media_elements.*, (SELECT COUNT (*) FROM bookmarks WHERE bookmarks.bookmarkable_type = #{self.class.connection.quote 'MediaElement'} AND bookmarks.bookmarkable_id = media_elements.id AND bookmarks.user_id = #{self.class.connection.quote self.id.to_i}) AS bookmarks_count, (SELECT COUNT(*) FROM media_elements_slides WHERE (media_elements_slides.media_element_id = media_elements.id)) AS instances"
    resp = {}
    order = ''
    case order_by
      when SearchOrders::UPDATED_AT
        order = 'updated_at DESC'
      when SearchOrders::TITLE
        order = 'title ASC, updated_at DESC'
    end
    count = 0
    query = []
    case filter
      when Filters::ALL_MEDIA_ELEMENTS
        count = MediaElement.where('is_public = ? OR user_id = ?', true, self.id).count
        query = MediaElement.select(select).where('is_public = ? OR user_id = ?', true, self.id).order(order).offset(offset).limit(limit)
      when Filters::VIDEO
        count = Video.where('is_public = ? OR user_id = ?', true, self.id).count
        query = Video.select(select).where('is_public = ? OR user_id = ?', true, self.id).order(order).offset(offset).limit(limit)
      when Filters::AUDIO
        count = Audio.where('is_public = ? OR user_id = ?', true, self.id).count
        query = Audio.select(select).where('is_public = ? OR user_id = ?', true, self.id).order(order).offset(offset).limit(limit)
      when Filters::IMAGE
        count = Image.where('is_public = ? OR user_id = ?', true, self.id).count
        query = Image.select(select).where('is_public = ? OR user_id = ?', true, self.id).order(order).offset(offset).limit(limit)
    end
    resp[:records] = []
    query.each do |q|
      q.set_status self.id, {:bookmarked => :bookmarks_count}
      resp[:records] << q
    end
    resp[:records_amount] = count
    resp[:pages_amount] = Rational(resp[:records_amount], limit).ceil
    return resp
  end
  
  # Submethod of User.search_lessons: if +word+ is a Fixnum, it extracts all the lessons associated to that word, otherwise it extracts all the lessons whose tags match the +word+. Results are filtered by the +filter+ (chosen among the ones in Filters) and by +subject_id+, and ordered by +order_by+ (chosen among SearchOrders)
  def search_lessons_with_tag(word, offset, limit, filter, subject_id, order_by, school_level_id)
    resp = {}
    params = ["#{word}%"]
    select = 'lessons.id AS my_lesson_id'
    joins = "INNER JOIN tags ON (tags.id = taggings.tag_id) INNER JOIN lessons ON (taggings.taggable_type = 'Lesson' AND taggings.taggable_id = lessons.id)"
    where = 'tags.word LIKE ?'
    if word.class == Fixnum
      params = [word]
      joins = "INNER JOIN lessons ON (taggings.taggable_type = 'Lesson' AND taggings.taggable_id = lessons.id)"
      where = 'taggings.tag_id = ?'
    end
    order = ''
    case order_by
      when SearchOrders::UPDATED_AT
        order = 'lessons.updated_at DESC'
      when SearchOrders::LIKES
        select = "#{select}, (SELECT COUNT(*) FROM likes WHERE (likes.lesson_id = lessons.id)) AS likes_count"
        order = 'likes_count DESC, lessons.updated_at DESC'
      when SearchOrders::TITLE
        order = 'lessons.title ASC, lessons.updated_at DESC'
    end
    if !subject_id.nil?
      where = "#{where} AND lessons.subject_id = ?"
      params << subject_id
    end
    if !school_level_id.nil?
      where = "#{where} AND lessons.school_level_id = ?"
      params << school_level_id
    end
    case filter
      when Filters::ALL_LESSONS
        where = "#{where} AND (lessons.is_public = ? OR lessons.user_id = ?)"
        params << true
        params << self.id
      when Filters::PUBLIC
        where = "#{where} AND lessons.is_public = ?"
        params << true
      when Filters::ONLY_MINE
        where = "#{where} AND lessons.user_id = ?"
        params << self.id
      when Filters::NOT_MINE
        where = "#{where} AND lessons.is_public = ? AND lessons.user_id != ?"
        params << true
        params << self.id
    end
    resp[:records] = []
    ids = []
    Tagging.group('lessons.id').select(select).joins(joins).where(where, *params).order(order).offset(offset).limit(limit).each do |single_lesson_item|
      ids << single_lesson_item.my_lesson_id.to_i
    end
    order = order.gsub('likes', 'likes_general')
    Lesson.preload(:subject, :user, :school_level, {:user => :location}).select("
      lessons.*,
      (SELECT COUNT (*) FROM bookmarks WHERE bookmarks.bookmarkable_type = #{self.class.connection.quote 'Lesson'} AND bookmarks.bookmarkable_id = lessons.id AND bookmarks.user_id = #{self.class.connection.quote self.id.to_i}) AS bookmarks_count,
      (SELECT COUNT (*) FROM bookmarks WHERE bookmarks.bookmarkable_type = #{self.class.connection.quote 'Lesson'} AND bookmarks.bookmarkable_id = lessons.id) AS all_bookmarks_count,
      (SELECT COUNT (*) FROM bookmarks WHERE bookmarks.bookmarkable_type = #{self.class.connection.quote 'Lesson'} AND bookmarks.bookmarkable_id = lessons.id AND bookmarks.user_id != #{self.class.connection.quote self.id} AND bookmarks.created_at < lessons.updated_at) AS notification_bookmarks,
      (SELECT COUNT (*) FROM virtual_classroom_lessons WHERE virtual_classroom_lessons.lesson_id = lessons.id AND virtual_classroom_lessons.user_id = #{self.class.connection.quote self.id.to_i}) AS virtuals_count,
      (SELECT COUNT (*) FROM likes WHERE likes.lesson_id = lessons.id AND likes.user_id = #{self.class.connection.quote self.id.to_i}) AS likes_count,
      (SELECT COUNT (*) FROM likes WHERE likes.lesson_id = lessons.id) AS likes_general_count
    ").where(:id => ids).order(order).each do |lesson|
      lesson.set_status self.id, {:bookmarked => :bookmarks_count, :in_vc => :virtuals_count, :liked => :likes_count}
      resp[:records] << lesson
    end
    resp[:records_amount] = Tagging.group('lessons.id').joins(joins).where(where, *params).count.length
    resp[:pages_amount] = Rational(resp[:records_amount], limit).ceil
    resp[:covers] = {}
    Slide.where(:lesson_id => ids, :kind => 'cover').preload(:media_elements_slides, {:media_elements_slides => :media_element}).each do |cov|
      resp[:covers][cov.lesson_id] = cov
    end
    return resp
  end
  
  # Submethod of User#search_lessons. It returns all the lessons in the database, filtered by +filter+ (chosen among the ones in Filters) and by +subject_id+, and ordered by +order_by+ (chosen among the ones in SearchOrders)
  def search_lessons_without_tag(offset, limit, filter, subject_id, order_by, school_level_id)
    resp = {}
    params = []
    where = ''
    order = ''
    select = "
      lessons.*,
      (SELECT COUNT (*) FROM bookmarks WHERE bookmarks.bookmarkable_type = #{self.class.connection.quote 'Lesson'} AND bookmarks.bookmarkable_id = lessons.id AND bookmarks.user_id = #{self.class.connection.quote self.id.to_i}) AS bookmarks_count,
      (SELECT COUNT (*) FROM bookmarks WHERE bookmarks.bookmarkable_type = #{self.class.connection.quote 'Lesson'} AND bookmarks.bookmarkable_id = lessons.id) AS all_bookmarks_count,
      (SELECT COUNT (*) FROM bookmarks WHERE bookmarks.bookmarkable_type = #{self.class.connection.quote 'Lesson'} AND bookmarks.bookmarkable_id = lessons.id AND bookmarks.user_id != #{self.class.connection.quote self.id} AND bookmarks.created_at < lessons.updated_at) AS notification_bookmarks,
      (SELECT COUNT (*) FROM virtual_classroom_lessons WHERE virtual_classroom_lessons.lesson_id = lessons.id AND virtual_classroom_lessons.user_id = #{self.class.connection.quote self.id.to_i}) AS virtuals_count,
      (SELECT COUNT (*) FROM likes WHERE likes.lesson_id = lessons.id AND likes.user_id = #{self.class.connection.quote self.id.to_i}) AS likes_count,
      (SELECT COUNT (*) FROM likes WHERE likes.lesson_id = lessons.id) AS likes_general_count
    "
    case order_by
      when SearchOrders::UPDATED_AT
        order = 'updated_at DESC'
      when SearchOrders::LIKES
        order = 'likes_general_count DESC, updated_at DESC'
      when SearchOrders::TITLE
        order = 'title ASC, updated_at DESC'
    end
    case filter
      when Filters::ALL_LESSONS
        where = '(is_public = ? OR user_id = ?)'
        params << true
        params << self.id
      when Filters::PUBLIC
        where = 'is_public = ?'
        params << true
      when Filters::ONLY_MINE
        where = 'user_id = ?'
        params << self.id
      when Filters::NOT_MINE
        where = 'is_public = ? AND user_id != ?'
        params << true
        params << self.id
    end
    if !subject_id.nil?
      where = "#{where} AND subject_id = ?"
      params << subject_id
    end
    if !school_level_id.nil?
      where = "#{where} AND school_level_id = ?"
      params << school_level_id
    end
    resp[:records] = []
    ids = []
    Lesson.preload(:subject, :user, :school_level, {:user => :location}).select(select).where(where, *params).order(order).offset(offset).limit(limit).each do |lesson|
      lesson.set_status self.id, {:bookmarked => :bookmarks_count, :in_vc => :virtuals_count, :liked => :likes_count}
      ids << lesson.id
      resp[:records] << lesson
    end
    resp[:records_amount] = Lesson.where(where, *params).count
    resp[:pages_amount] = Rational(resp[:records_amount], limit).ceil
    resp[:covers] = {}
    Slide.where(:lesson_id => ids, :kind => 'cover').preload(:media_elements_slides, {:media_elements_slides => :media_element}).each do |cov|
      resp[:covers][cov.lesson_id] = cov
    end
    return resp
  end
  
  # Initializes validation objects (see Valid.get_association)
  def init_validation
    @user = Valid.get_association self, :id
    @school_level = Valid.get_association self, :school_level_id
    @purchase = Valid.get_association self, :purchase_id
  end
  
  # Validates that there are not too many users associated to the same purchase
  def validate_accounts_number_for_purchase
    if @user
      errors.add(:purchase_id, :too_many_users_for_purchase) if @purchase && self.purchase_id != @user.purchase_id && @purchase.accounts_number <= User.where(:purchase_id => self.purchase_id).count
    else
      errors.add(:purchase_id, :too_many_users_for_purchase) if @purchase && @purchase.accounts_number <= User.where(:purchase_id => self.purchase_id).count
    end
  end
  
  # Validates the presence of all the associated objects
  def validate_associations
    errors.add :school_level_id, :doesnt_exist if @school_level.nil?
    errors.add :purchase_id, :doesnt_exist if @purchase.nil? && self.purchase_id.present?
    if self.location_id
      @location = Valid.get_association self, :location_id
      errors.add :location_id, :doesnt_exist if @location.nil? || @location.sti_type != SETTINGS['location_types'].last
    end
  end
  
  # If the user is not new, it validates that the email didn't change
  def validate_email_not_changed
    errors.add :email, :changed if changed.include? 'email'
  end
  
  # Validates the correct format of the email (see Valid.email?)
  def validate_email
    return if self.email.blank?
    errors.add(:email, :not_a_valid_email) if !Valid.email?(self.email)
  end
  
end

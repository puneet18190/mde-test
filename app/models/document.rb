require 'filename_token'

# ### Description
#
# ActiveRecord class that corresponds to the table +documents+.
#
# ### Fields
#
# * *user_id*: id of the creator of the document
# * *title*: title
# * *description*: description
# * *attachment*: attached file
# * *metadata*: contains:
#   * +size+: dimension of the attached file
#
# ### Associations
#
# * *user*: reference to the User who created the document (*belongs_to*)
# * *documents_slides*: instances of this Document contained in a slide (see DocumentsSlide) (*has_many*)
#
# ### Validations
#
# * *presence* with numericality and existence of associated record for +user_id+
# * *presence* for +title+ and +attachment+
# * *length* of +title+ and +description+ (values configured in the I18n translation file; only for title, if the value is greater than 255 it's set to 255)
# * *modifications* *not* *available* for the +user_id+
#
# ### Callbacks
#
# 1. *before_validation* saves the +title+ from the attachment if it's not present
# 2. *before_save* sets the +size+ in metadata
#
# ### Database callbacks
#
# 1. *cascade* *destruction* for the associated table DocumentsSlide
#
class Document < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include Rails.application.routes.url_helpers
  include FilenameToken
  include UrlTypes
  
  # Maximum length of the title
  MAX_TITLE_LENGTH = (I18n.t('language_parameters.document.length_title') > 255 ? 255 : I18n.t('language_parameters.document.length_title'))
  
  # Maximum attachment size expressed in megabytes
  MAX_ATTACHMENT_SIZE = SETTINGS['max_document_size'].megabytes
  
  # List of accepted types
  TYPES_BY_EXTENSION = {
    '.ppt'     => :ppt,
    '.pptx'    => :ppt,
    '.keynote' => :ppt,
    '.odp'     => :ppt,
    '.doc'     => :doc,
    '.docx'    => :doc,
    '.pages'   => :doc,
    '.odt'     => :doc,
    '.txt'     => :doc,
    '.zip'     => :zip,
    '.gz'      => :zip,
    '.xls'     => :exc,
    '.xlsx'    => :exc,
    '.numbers' => :exc,
    '.ods'     => :exc,
    '.pdf'     => :pdf,
    '.ps'      => :pdf,
  }
  
  # Colors of the icons by type
  COLORS_BY_TYPE = {
    :ppt     => '#F6921E',
    :doc     => '#26A9E0',
    :zip     => '#57585B',
    :exc     => '#37B34A',
    :pdf     => '#EC1C24',
    :unknown => '#A7A9AC'
  }
  
  serialize :metadata, OpenStruct
    
  mount_uploader :attachment, DocumentUploader
  
  belongs_to :user
  has_many :documents_slides
  
  validates_presence_of :user_id, :title, :description, :attachment
  validates_numericality_of :user_id, :only_integer => true, :greater_than => 0
  validates_length_of :title, :maximum => MAX_TITLE_LENGTH
  validates_length_of :description, :maximum => I18n.t('language_parameters.document.length_description')
  validate :validate_associations, :validate_impossible_changes, :validate_size, :validate_maximum_folder_size
  
  before_validation :init_validation
  before_save :set_size
  
  # Returns the size and extension in a nice way for the views
  def size_and_extension
    "#{extension.sub /\A\./, ''}, #{human_size}"
  end
  
  # Checks in the list of accepted types
  def type
    TYPES_BY_EXTENSION.fetch extension, :unknown
  end
  
  # Returns the icon, depending on the extension
  def icon_url(url_type = nil)
    url_by_url_type "/assets/documents/#{type.to_s}.svg", url_type
  end
  
  # Returns the title associated to the icon
  def icon_title
    I18n.t("titles.documents.#{type.to_s}")
  end
  
  # Returns the extension of the attachment after an upload
  def uploaded_filename_without_extension
    attachment.try(:original_filename_without_extension)
  end
  
  # Returns the size
  def size
    metadata.size
  end
  
  # Sets the size
  def size=(size)
    metadata.size = size
  end
  
  # Renders the size with mega, giga, etc
  def human_size
    number_to_human_size size
  end
  
  def extension
    attachment.original_extension || attachment ? File.extname(attachment.path) : nil
  end
  
  # Returns the url
  def url(url_type = nil)
    url = attachment.url
    url_by_url_type url, url_type
  end
  
  # Returns true if the document has been attached to your own lessons
  def used_in_your_lessons?
    DocumentsSlide.joins(:slide, {:slide => :lesson}).where(:documents_slides => {:document_id => self.id}, :lessons => {:user_id => self.user_id}).any?
  end
  
  # ### Description
  #
  # Destroys the document and sends notifications to the users who had a Lesson containing it.
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
      DocumentsSlide.joins(:slide, {:slide => :lesson}).select('lessons.user_id AS my_user_id, lessons.title AS lesson_title, lessons.id AS lesson_id').group('lessons.id').where('documents_slides.document_id = ?', self.id).each do |ds|
        n_title = I18n.t('notifications.documents.destroyed.title')
        n_message = I18n.t('notifications.documents.destroyed.message', :document_title => self.title, :lesson_title => ds.lesson_title)
        n_basement = I18n.t('notifications.documents.destroyed.basement', :lesson_title => ds.lesson_title, :link => lesson_viewer_path(ds.lesson_id.to_i))
        if ds.my_user_id.to_i != self.user_id && !Notification.send_to(ds.my_user_id.to_i, n_title, n_message, n_basement)
          errors.add(:base, :problem_destroying)
          raise ActiveRecord::Rollback
        end
        Bookmark.where(:bookmarkable_type => 'Lesson', :bookmarkable_id => ds.lesson_id.to_i).each do |b|
          automatic_message = I18n.t('notifications.documents.standard_message_for_linked_lessons', :document_title => self.title)
          n_title = I18n.t('notifications.lessons.modified.title')
          n_message = I18n.t('notifications.lessons.modified.message', :lesson_title => ds.lesson_title, :message => automatic_message)
          n_basement = I18n.t('notifications.lessons.modified.basement', :lesson_title => ds.lesson_title, :link => lesson_viewer_path(ds.lesson_id.to_i))
          if !Notification.send_to(b.user_id, n_title, n_message, n_basement)
            errors.add(:base, :problem_destroying)
            raise ActiveRecord::Rollback
          end
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
  
  private
  
  # Validates the size of the attached file, comparing it to the maximum size configured in megabytes in settings.yml
  def validate_size
    if attachment.present? && attachment.file.size > MAX_ATTACHMENT_SIZE
      errors.add(:attachment, :too_large)
    end
  end
  
  # Validates the sum of the documents folder size to don't exceed the maximum size available
  def validate_maximum_folder_size
    errors.add :attachment, :folder_size_exceeded if DocumentUploader.maximum_folder_size_exceeded?
  end
  
  # Sets the size (callback)
  def set_size
    self.size = attachment.size if attachment.size
  end
  
  # Validates the presence of all the associated objects
  def validate_associations
    errors.add(:user_id, :doesnt_exist) if @user.nil?
  end
  
  # Initializes validation objects (see Valid.get_association)
  def init_validation
    @document = Valid.get_association self, :id
    @user = Valid.get_association self, :user_id
  end
  
  # Validates that if the document is not new record the field +user_id+ cannot be changed
  def validate_impossible_changes
    errors.add(:user_id, :cant_be_changed) if @document && @document.user_id != self.user_id
  end
  
end

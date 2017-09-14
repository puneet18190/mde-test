# ### Description
#
# ActiveRecord class that corresponds to the table +reports+: this table contains reports of inappropriate content sent by users about lessons or media elements.
#
# ### Fields
#
# * *reportable_id*: id of the item (lesson or media element) the report is about
# * *reportable_type*: contains the string description of the classes Lesson or MediaElement (the type is an enum defined in postgrsql)
# * *user_id*: id of the User who sent the report
# * *comment*: text message associated to the report
#
# ### Associations
#
# * *user*: User who sent the report (*belongs_to*)
# * *reportable*: Lesson or MediaElement reported (polymorphic association) (*belongs_to*)
#
# ### Validations
#
# * *presence* with numericality and existence of associated record for +user_id+ and +reportable_id+
# * *presence* of +content+
# * *inclusion* of +reportable_type+ between 'Lesson' and 'MediaElement'
# * *uniqueness* of the triple [+user_id+, +reportable_type+, +reportable_id+] <b>only if +reportable_type+ is correct</b>
# * *modifications* *not* *available* for the four fields, if the record is not new
#
# ### Callbacks
#
# None
#
# ### Database callbacks
#
# None
#
class Report < ActiveRecord::Base
  
  belongs_to :reportable, :polymorphic => true
  belongs_to :user
  
  validates_presence_of :user_id, :reportable_id, :comment
  validates_numericality_of :user_id, :reportable_id, :only_integer => true, :greater_than => 0
  validates_inclusion_of :reportable_type, :in => ['Lesson', 'MediaElement']
  validates_uniqueness_of :reportable_id, :scope => [:user_id, :reportable_type], :if => :good_reportable_type
  validate :validate_associations, :validate_impossible_changes
  
  before_validation :init_validation
  
  # ### Description
  #
  # The report is accepted as valid: hence the associated Lesson or MediaElement is destroyed, together with the report itself (used in Admin::ReportsController#accept).
  #
  def accept
    to_be_destroyed = self.reportable
    to_be_destroyed.destroyable_even_if_public = true if self.reportable_type == 'MediaElement'
    to_be_destroyed.destroy
    self.destroy
  end
  
  # ### Description
  #
  # The report is not accepted as valid: hence the associated Lesson or MediaElement is not destroyed. The report is destroyed in any case (used in Admin::ReportsController#decline).
  #
  def decline
    self.destroy
  end
  
  private
  
  # Checks if the format of +reportable_type+ is correct
  def good_reportable_type
    ['Lesson', 'MediaElement'].include? self.reportable_type
  end
  
  # Initializes validation objects (see Valid.get_association)
  def init_validation
    @report = Valid.get_association self, :id
    @user = Valid.get_association self, :user_id
    @lesson = self.reportable_type == 'Lesson' ? Valid.get_association(self, :reportable_id, Lesson) : nil
    @media_element = self.reportable_type == 'MediaElement' ? Valid.get_association(self, :reportable_id, MediaElement) : nil
  end
  
  # Validates the presence of all the associated objects
  def validate_associations
    errors.add(:user_id, :doesnt_exist) if @user.nil?
    errors.add(:reportable_id, :lesson_doesnt_exist) if self.reportable_type == 'Lesson' && @lesson.nil?
    errors.add(:reportable_id, :media_element_doesnt_exist) if self.reportable_type == 'MediaElement' && @media_element.nil?
  end
  
  # If the report is not a new record, it validates that no field can be changed
  def validate_impossible_changes
    if @report
      errors.add(:user_id, :cant_be_changed) if self.user_id != @report.user_id
      errors.add(:reportable_id, :cant_be_changed) if self.reportable_id != @report.reportable_id
      errors.add(:reportable_type, :cant_be_changed) if self.reportable_type != @report.reportable_type
      errors.add(:comment, :cant_be_changed) if self.comment != @report.comment
    end
  end
  
end

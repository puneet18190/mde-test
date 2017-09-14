# ### Description
#
# ActiveRecord class that corresponds to the table +mailing_list_addresses+.
#
# ### Fields
# 
# * *group_id*: the reference to MailingListGroup
# * *heading*: the name that the user associates to the e-mail address
# * *email*: eht email address
#
# ### Associations
#
# * *group*: reference to the MailingListGroup to which the address belongs (*belongs_to*)
#
# ### Validations
#
# * *presence* for +email+ and +heading+
# * *presence* with numericality and existence of associated record for +group_id+
# * *length* of +heading+ and +email+, maximum is 255
# * *correctness* of +email+ as an e-mail address
# * *modifications* *not* *available* for +group_id+, if the record is not new
#
# ### Callbacks
#
# None
#
# ### Database callbacks
#
# None
#
class MailingListAddress < ActiveRecord::Base
    
  belongs_to :group, class_name: MailingListGroup
  
  validates_presence_of :email, :heading, :group_id
  validates_numericality_of :group_id, :greater_than => 0, :only_integer => true
  validates_length_of :heading, :email, :maximum => 255
  validate :validate_associations, :validate_impossible_changes, :validate_email
  
  before_validation :init_validation
  
  private
  
  # Initializes validation objects (see Valid.get_association)
  def init_validation
    @group = Valid.get_association(self, :group_id, MailingListGroup)
    @mailing_list_address = Valid.get_association self, :id
  end
  
  # Validates the presence of all the associated objects
  def validate_associations
    errors.add(:group_id, :doesnt_exist) if @group.nil?
  end
  
  # If the group is not a new record, the field +group_id+ can't be changed
  def validate_impossible_changes
    errors.add(:group_id, :cant_be_changed) if @mailing_list_address && @mailing_list_address.group_id != self.group_id
  end
  
  # Validates the correct format of the email (see Valid.email?)
  def validate_email
    return if self.email.blank?
    errors.add(:email, :not_a_valid_email) if !Valid.email?(self.email)
  end
  
end

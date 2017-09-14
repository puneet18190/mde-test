# ### Description
#
# ActiveRecord model associated to the table 'users_subjects': this table is used as a link association of type +has_and_belongs_to_many+ between the models User and Subject
#
# ### Fields
#
# * *user_id*: id of the user
# * *subject_id*: id of the subject
#
# ### Associations
#
# * *user*: the User who owns this instance of a subject (*belongs_to*)
# * *subject*: the Subject instanced (*belongs_to*)
#
# ### Validations
#
# * *presence* with numericality greater than 0 and presence of associated object for both fields
#
# ### Callbacks
#
# None
#
# ### Database callbacks
#
# None
#
class UsersSubject < ActiveRecord::Base
    
  belongs_to :user
  belongs_to :subject
  
  validates_presence_of :user, if: proc{ |r| r.user_id.blank? }
  validates_presence_of :subject, if: proc{ |r| r.subject_id.blank? }
  validates_presence_of :user_id, if: proc{ |r| r.user.blank? }
  validates_presence_of :subject_id, if: proc{ |r| r.subject.blank? }
  validates_uniqueness_of :subject_id, :scope => :user_id
  
end

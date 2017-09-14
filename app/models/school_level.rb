# ### Description
#
# ActiveRecord class that corresponds to the table +school_levels+.
#
# ### Fields
#
# * *description*: a word identifying the school level
#
# ### Associations
#
# * *users*: list of users who are associated to this school level (see User) (*has_many*)
# * *lessons*: list of lessons associated to this school level (see Lesson) (*has_many*)
#
# ### Validations
#
# * *presence* of +description+
# * *length* of +description+ (maximum allowed is 255)
#
# ### Callbacks
#
# None
#
# ### Database callbacks
#
# None
#
class SchoolLevel < ActiveRecord::Base
    
  has_many :lessons
  has_many :users
  
  validates_presence_of :description
  validates_length_of :description, :maximum => 255
  
  # ### Description
  #
  # Returns the description of the object
  #
  def to_s
    description.to_s
  end
  
  # ### Description
  #
  # A school level is deletable if it has no associated lessons or users. Used in the administrator (Admin::SettingsController#school_levels)
  #
  # ### Returns
  #
  # A boolean
  #
  def is_deletable?
    User.where(:school_level_id => self.id).empty? && Lesson.where(:school_level_id => self.id).empty?
  end
  
end

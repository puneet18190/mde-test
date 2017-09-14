# ### Description
#
# ActiveRecord class that corresponds to the table +likes+. A record of this table represents the 'I like you' that a user assigns to a lesson
#
# ### Fields
#
# * *user_id*: id of the User creator of the like
# * *lesson_id*: id of liked Lesson
#
# ### Associations
#
# * *user*: reference to the User who created the like (*belongs_to*).
# * *lesson*: liked Lesson (*belongs_to*).
#
# ### Validations
#
# * *presence* with numericality and existence of associated record for +user_id+ and +lesson_id+
# * *uniqueness* of the couple [+lesson_id+, +user_id+]
# * *modifications* *not* *available* for both fields, if the record is not new
# * *availability* of the Lesson for that particular User (the user can't be the creator of the lesson)
#
# ### Callbacks
#
# None
#
# ### Database callbacks
#
# None
#
class Like < ActiveRecord::Base
  
  belongs_to :lesson
  belongs_to :user
  
  validates_presence_of :lesson_id, :user_id
  validates_numericality_of :lesson_id, :user_id, :only_integer => true, :greater_than => 0
  validates_uniqueness_of :lesson_id, :scope => :user_id
  validate :validate_associations, :validate_impossible_changes, :validate_availability
  
  before_validation :init_validation
  
  private
  
  # Validates the presence of all the associated objects
  def validate_associations
    errors.add(:user_id, :doesnt_exist) if @user.nil?
    errors.add(:lesson_id, :doesnt_exist) if @lesson.nil?
  end
  
  # Initializes validation objects (see Valid.get_association)
  def init_validation
    @like = Valid.get_association self, :id
    @lesson = Valid.get_association self, :lesson_id
    @user = Valid.get_association self, :user_id
  end
  
  # If the like is not a new record, +user_id+ and +lesson_id+ cannot be modified
  def validate_impossible_changes
    if @like
      errors.add(:user_id, :cant_be_changed) if @like.user_id != self.user_id
      errors.add(:lesson_id, :cant_be_changed) if @like.lesson_id != self.lesson_id
    end
  end
  
  # Validates that the liked Lesson is not owned by the liker
  def validate_availability
    errors.add(:lesson_id, :cant_be_liked) if @lesson && @user && @lesson.user_id == @user.id
  end
  
end

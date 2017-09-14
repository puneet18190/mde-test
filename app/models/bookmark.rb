# ### Description
#
# ActiveRecord class that corresponds to the table +bookmarks+. A bookmark can be associated to either a Lesson or a MediaElement.
#
# ### Fields
#
# * *bookmarkable_id*: id of the item (lesson or media element) to which the bookmark is associated
# * *bookmarkable_type*: contains the string description of the classes Lesson or MediaElement (the type is an enum defined in postgrsql)
# * *user_id*: id of the user associated to the bookmark
#
# ### Associations
#
# * *user*: User who bookmarked (*belongs_to*)
# * *bookmarkable*: Lesson or MediaElement bookmarked (polymorphic association) (*belongs_to*)
#
# ### Validations
#
# * *presence* with numericality and existence of associated record for +user_id+ and +bookmarkable_id+
# * *inclusion* of +bookmarkable_type+ between 'Lesson' and 'MediaElement'
# * *uniqueness* of the triple [+user_id+, +bookmarkable_type+, +bookmarkable_id+] <b>only if +bookmarkable_type+ is correct</b>
# * *availability* of the associated item (for lessons it can't be public and it can't belong to the user who bookmarks, for media elements it can't be public)
# * *modifications* *not* *available* for the three fields, if the record is not new
#
# ### Callbacks
#
# 1. *before_destroy*: destroy (not directly) associated VirtualClassroomLesson, if there are any.
#
# ### Database callbacks
#
# None.
#
class Bookmark < ActiveRecord::Base
  
  belongs_to :bookmarkable, :polymorphic => true
  belongs_to :user
  
  validates_presence_of :user_id, :bookmarkable_id
  validates_numericality_of :user_id, :bookmarkable_id, :only_integer => true, :greater_than => 0
  validates_inclusion_of :bookmarkable_type, :in => ['Lesson', 'MediaElement']
  validates_uniqueness_of :bookmarkable_id, :scope => [:user_id, :bookmarkable_type], :if => :good_bookmarkable_type
  validate :validate_associations, :validate_availability, :validate_impossible_changes
  
  before_validation :init_validation
  before_destroy :destroy_virtual_classroom
  
  private
  
  # Initializes validation objects (see Valid.get_association)
  def init_validation
    @user = Valid.get_association self, :user_id
    @bookmark = Valid.get_association self, :id
    @lesson = self.bookmarkable_type == 'Lesson' ? Valid.get_association(self, :bookmarkable_id, Lesson) : nil
    @media_element = self.bookmarkable_type == 'MediaElement' ? Valid.get_association(self, :bookmarkable_id, MediaElement) : nil
  end
  
  # True if +bookmarkable_type+ is in the correct syntax
  def good_bookmarkable_type
    ['Lesson', 'MediaElement'].include? self.bookmarkable_type
  end
  
  # Validates the presence of all the associated objects
  def validate_associations
    errors.add(:user_id, :doesnt_exist) if @user.nil?
    errors.add(:bookmarkable_id, :lesson_doesnt_exist) if self.bookmarkable_type == 'Lesson' && @lesson.nil?
    errors.add(:bookmarkable_id, :media_element_doesnt_exist) if self.bookmarkable_type == 'MediaElement' && @media_element.nil?
  end
  
  # For lessons, validates that it doesn't belong to the user and that it's public
  # For elements, it validates that the element is public
  def validate_availability
    errors.add(:bookmarkable_id, :lesson_not_available_for_bookmarks) if @lesson && (@lesson.user_id == self.user_id || !@lesson.is_public)
    errors.add(:bookmarkable_id, :media_element_not_available_for_bookmarks) if @media_element && !@media_element.is_public
  end
  
  # Callback that destroys the associated record of VirtualClassroomLesson
  def destroy_virtual_classroom
    return if self.new_record?
    bookmark_me = Bookmark.find self.id
    return if bookmark_me.bookmarkable_type != 'Lesson'
    vc = VirtualClassroomLesson.where(:lesson_id => bookmark_me.bookmarkable_id, :user_id => bookmark_me.user_id).first
    return if vc.nil?
    vc.destroy
    return false if VirtualClassroomLesson.where(:lesson_id => bookmark_me.bookmarkable_id, :user_id => bookmark_me.user_id).any?
  end
  
  # If not new record, none of the fields can be changed
  def validate_impossible_changes
    if @bookmark
      errors.add(:user_id, :cant_be_changed) if self.user_id != @bookmark.user_id
      errors.add(:bookmarkable_id, :cant_be_changed) if self.bookmarkable_id != @bookmark.bookmarkable_id
      errors.add(:bookmarkable_type, :cant_be_changed) if self.bookmarkable_type != @bookmark.bookmarkable_type
    end
  end
  
end

# ### Description
#
# ActiveRecord class that corresponds to the table +taggings+. A tagging is an instance of a tag on a Lesson or a MediaElement.
#
# ### Fields
#
# * *taggable_id*: id of the item (lesson or media element) to which the tag is associated
# * *taggable_type*: contains the string description of the classes Lesson or MediaElement (the type is an enum defined in postgrsql)
# * *tag_id*: id of the Tag associated to the item
#
# ### Associations
#
# * *tag*: associated Tag (*belongs_to*)
# * *taggable*: Lesson or MediaElement tagged (polymorphic association) (*belongs_to*)
#
# ### Validations
#
# * *presence* with numericality and existence of associated record for +tag_id+ and +taggable_id+
# * *inclusion* of +taggable_type+ between 'Lesson' and 'MediaElement'
# * *uniqueness* of the triple [+tag_id+, +taggable_type+, +taggable_id+] <b>only if +taggable_type+ is correct</b>
# * *modifications* *not* *available* for the three fields, if the record is not new
#
# ### Callbacks
#
# 1. *after_destroy*: destroys the associated Tag, if this tagging was the last attached to it: <b>this happens only if the attribute not_orphans is set as true</b>
#
# ### Database callbacks
#
# None.
#
class Tagging < ActiveRecord::Base
  
  # Used to skip the +after_destroy+ callback
  attr_writer :not_orphans
  
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true
  
  validates_presence_of :tag_id, :taggable_id
  validates_numericality_of :tag_id, :taggable_id, :only_integer => true, :greater_than => 0
  validates_inclusion_of :taggable_type, :in => ['Lesson', 'MediaElement']
  validates_uniqueness_of :taggable_id, :scope => [:tag_id, :taggable_type], :if => :good_taggable_type
  validate :validate_associations, :validate_impossible_changes
  
  before_validation :init_validation
  after_destroy :destroy_orphan_tags
  
  # ### Description
  #
  # Used as support for Lesson#visive_tags and MediaElement#visive_tags
  #
  # ### Args
  #
  # * *tags*: the string containing tags in the shape ',tag1,tag2,tag3,tag4,'
  #
  # ### Returns
  #
  # A string of tags separated by comma and space
  #
  def self.visive_tags(tags)
    tags[1, tags.length].chop.gsub(',', ', ')
  end
  
  private
  
  # Callback that destroys the attached Tag if it doesn't have attached taggings anymore. The callback is not fired if the attribute not_orphans is +true+
  def destroy_orphan_tags
    return true if @not_orphans
    tag.destroy if !tag.taggings.exists?
    true
  end
  
  # Checks that +taggable_type+ is in the correct format
  def good_taggable_type
    ['Lesson', 'MediaElement'].include? self.taggable_type
  end
  
  # Initializes validation objects (see Valid.get_association)
  def init_validation
    @tagging = Valid.get_association self, :id
    @lesson = self.taggable_type == 'Lesson' ? Valid.get_association(self, :taggable_id, Lesson) : nil
    @media_element = self.taggable_type == 'MediaElement' ? Valid.get_association(self, :taggable_id, MediaElement) : nil
  end
  
  # Validates the presence of all the associated objects
  def validate_associations
    errors.add(:tag_id, :doesnt_exist) if !Tag.exists?(self.tag_id)
    errors.add(:taggable_id, :lesson_doesnt_exist) if self.taggable_type == 'Lesson' && @lesson.nil?
    errors.add(:taggable_id, :media_element_doesnt_exist) if self.taggable_type == 'MediaElement' && @media_element.nil?
  end
  
  # If not a new record, it validates that no field changed
  def validate_impossible_changes
    if @tagging
      errors.add(:tag_id, :cant_be_changed) if self.tag_id != @tagging.tag_id
      errors.add(:taggable_id, :cant_be_changed) if self.taggable_id != @tagging.taggable_id
      errors.add(:taggable_type, :cant_be_changed) if self.taggable_type != @tagging.taggable_type
    end
  end
  
end

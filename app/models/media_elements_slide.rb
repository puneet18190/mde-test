# ### Description
#
# ActiveRecord class that corresponds to the table +media_elements_slides+: this table contains all the instances of media elements inside a slide.
#
# ### Fields
#
# * *media_element_id*: the id that references MediaElement
# * *slide_id*: the id that references Slide
# * *position*: the position of the media element inside the slide, (if there is only one element available, the position is 1)
# * *caption*: the caption to put below the media element, if it's an image
# * *alignment*: the alignment of the media element, if it's an image
# * *inscribed*: true if the image is inscribed inside the available space without parts left outside
#
# ### Associations
#
# * *media_element*: reference to the MediaElement of which the slide contains an instance (*belongs_to*)
# * *slide*: reference to the Slide in which the media element is saved (*belongs_to*)
# * *lesson*: reference to the Lesson containing the Slide in which the media element is saved (*has_one*)
#
# ### Validations
#
# * *presence* with numericality and existence of associated record for +media_element_id+ and +slide_id+
# * *numericality* allowing +nil+ values for +alignment+
# * *inclusion* of +position+ in [1, 2, 3, 4]
# * *inclusion* of +inscribed+ in [true, false]
# * *uniqueness* of the triple [+position+, +media_element_id+, +slide_id+]
# * *coherence* of the type of the Slide with the MediaElement
# * *coherence* of the +position+ with the type of the Slide (if the slide is of kind image1 it may have for instance only position = 1)
# * *availability* of the MediaElement (it must be public or belongs to the User who created the Lesson in which the Slide is contained)
# * *modifications* *not* *available* for the field +slide_id+
# * *properties* *specific* *for* *images*, such as +alignment+ and +caption+ are checked to be present only if the MediaElement is an Image
# * *inscribed* *cannot* *be* *true* if the element is not an image
#
# ### Callbacks
#
# 1. *after_destroy* if the element is an Audio or Video in conversion, and it was the last present on the Lesson containing the referenced Slide, the lesson is turned available using Lesson#available!
#
# ### Database callbacks
#
# None
#
class MediaElementsSlide < ActiveRecord::Base
    
  belongs_to :media_element
  belongs_to :slide
  has_one :lesson, through: :slide
  
  validates_presence_of :media_element_id, :slide_id
  validates_numericality_of :media_element_id, :slide_id, :only_integer => true, :greater_than => 0
  validates_numericality_of :alignment, :only_integer => true, :allow_nil => true
  validates_inclusion_of :position, :in => [1, 2, 3, 4]
  validates_inclusion_of :inscribed, :in => [true, false]
  validates_uniqueness_of :position, :scope => [:media_element_id, :slide_id]
  validate :validate_associations, :validate_type_in_slide, :validate_position, :validate_media_element, :validate_impossible_changes, :validate_image_properties
  
  before_validation :init_validation
  
  after_destroy :restore_lesson_availability
  
  # ### Description
  #
  # Returns media_element.background_position. media_element must be an Image.
  #
  # ### Returns
  #
  # A value compliant to background-position
  #
  def background_position
    media_element.background_position slide.kind, alignment
  end

  def background_size
    inscribed ? 'contain' : 'cover'
  end

  # ### Description
  #
  # Method to check that it's horizontal
  #
  # ### Args
  #
  # * *kind*: the kind of the slide (it can be nil)
  #
  # ### Returns
  #
  # A boolean
  #
  def is_horizontal?(kind = nil)
    media_element.is_horizontal?(kind || slide.kind)
  end
  
  # ### Description
  #
  # Method that resizes width according to the kind
  #
  # ### Args
  #
  # * *kind*: the kind of the slide (it can be nil)
  #
  # ### Returns
  #
  # A float
  #
  def resize_width(kind = nil)
    media_element.resize_width(kind || slide.kind)
  end
  
  # ### Description
  #
  # Method that resizes height according to the kind
  #
  # ### Args
  #
  # * *kind*: the kind of the slide (it can be nil)
  #
  # ### Returns
  #
  # A float
  #
  def resize_height(kind = nil)
    media_element.resize_height(kind || slide.kind)
  end
  
  private
  
  # Callback that restores as available = true the associated lesson, if this instance of the element was the last one locking it
  def restore_lesson_availability
    if media_element && 
       !media_element.converted? &&
       lesson &&
       !lesson.available?(media_element.sti_type) &&
       !lesson.media_elements.where(converted: false, sti_type: media_element.sti_type).where('media_elements.id != ?', media_element.id).exists?
      lesson.class.find(lesson.id).available!(media_element.class)
    end
    true
  end
  
  # Initializes validation objects (see Valid.get_association)
  def init_validation
    @media_elements_slide = Valid.get_association self, :id
    @slide = Valid.get_association self, :slide_id
    @media_element = Valid.get_association self, :media_element_id
  end
  
  # Validates that if the associated element is an image, the fields +alignment+ and +caption+ can't be null; if it's audio or video, the same fields must be null
  def validate_image_properties
    if @media_element
      if @media_element.image?
        errors.add(:alignment, :cant_be_null_if_image) if self.alignment.nil?
        if @slide && @slide.cover?
          errors.add(:inscribed, :must_be_false_if_cover) if self.inscribed
          errors.add(:caption, :must_be_null_if_cover) if !self.caption.blank?
        end
      else
        errors.add(:alignment, :must_be_null_if_not_image) if !self.alignment.nil?
        errors.add(:caption, :must_be_null_if_not_image) if !self.caption.blank?
        errors.add(:inscribed, :must_be_false_if_not_image) if self.inscribed
      end
    end
  end
  
  # Validates the presence of all the associated objects
  def validate_associations
    errors.add(:media_element_id, :doesnt_exist) if @media_element.nil?
    errors.add(:slide_id, :doesnt_exist) if @slide.nil?
  end
  
  # It validates the coherence of the type of the attached element with the type of the Slide
  def validate_type_in_slide
    errors.add(:media_element_id, :is_not_compatible_with_slide) if @media_element && @slide && @slide.accepted_media_element_sti_type != @media_element.sti_type
  end
  
  # Validates the maximum position according to the type of Slide
  def validate_position
    errors.add(:position, :cant_have_two_elements_in_this_slide) if @media_element && @slide && self.position == 2 && ![Slide::IMAGE2, Slide::IMAGE4].include?(@slide.kind)
    errors.add(:position, :cant_have_more_than_two_elements_in_this_slide) if @media_element && @slide && [3, 4].include?(self.position) && @slide.kind != Slide::IMAGE4
  end
  
  # Validates the availability of the attached element (it must be either public or mine)
  def validate_media_element
    errors.add(:media_element_id, :is_not_available) if @media_element && @slide && !@media_element.is_public && @media_element.user_id != @slide.lesson.user_id
  end
  
  # If new record, it validates that +slide_id+ can't be changed
  def validate_impossible_changes
    if @media_elements_slide
      errors.add(:slide_id, :cant_be_changed) if @media_elements_slide.slide_id != self.slide_id
    end
  end
  
end

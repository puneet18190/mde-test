# ### Description
#
# ActiveRecord class that corresponds to the table +tags+.
#
# ### Fields
#
# * *word*: the tag contained in the object
#
# ### Associations
#
# * *taggings*: list of instances associated to this tag (see Tagging) (*has_many*)
#
# ### Validations
#
# * *presence* of +word+
# * *length* of +word+ minimum and maximum allowed are configured in settings.yml
# * *uniqueness* of +word+
# * *modifications* *not* *available* for +word+
#
# ### Callbacks
#
# 1. *before_destroy* destroys associated taggings (this callback is written manually because before destroying a Tagging it's necessary to switch off the callback that destroy the assocaited tag if it was the last tagging associated)
#
# ### Database callbacks
#
# None
#
class Tag < ActiveRecord::Base
  
  MIN_LENGTH = SETTINGS['min_tag_length']
  MAX_LENGTH = (SETTINGS['max_tag_length'] > 255 ? 255 : SETTINGS['max_tag_length'])
    
  has_many :taggings
  
  validates_presence_of :word
  validates_length_of :word, :minimum => MIN_LENGTH, :maximum => MAX_LENGTH
  validates_uniqueness_of :word
  
  validate :word_not_changed
  
  before_validation :init_validation
  before_destroy :destroy_taggings
  
  # ### Description
  #
  # Method used in the autocomplete. It extracts the most used 20 tags matching the inserted word. If the word is already a tag itself, it adds it on top of the list, extracting the remaining 19 tags. Used in TagsController#get_list
  #
  # ### Args
  #
  # * *user*: the user who is autocompleting tags
  # * *a_word*: word to be autocompleted
  # * *item*: either 'lesson' or 'media_element'
  #
  # ### Return
  #
  # An array of tags
  #
  def self.get_tags_for_autocomplete(user, a_word, item)
    return [] if a_word.blank?
    a_word = a_word.to_s.strip.mb_chars.downcase.to_s
    resp = []
    curr_tag = Tag.find_by_word(a_word)
    limit = SETTINGS['how_many_tags_for_block_in_autocomplete']
    if !curr_tag.nil?
      resp << {:id => curr_tag.id, :value => a_word}
      limit -= 1
    end
    to_be_adapted = []
    if item == 'media_element'
      to_be_adapted = user.search_media_elements(a_word, 1, limit, nil, nil, true)
    else
      to_be_adapted = user.search_lessons(a_word, 1, limit, nil, nil, nil, true, nil)
    end
    if curr_tag
      to_be_adapted.each do |tba|
        resp << {:id => tba.id, :value => tba.word} if tba.word != a_word
      end
    else
      to_be_adapted.each do |tba|
        resp << {:id => tba.id, :value => tba.word}
      end
    end
    resp
  end
  
  # ### Description
  #
  # Used as a helper for the tag validations in Lesson and MediaElement (it's used to fill the private attribute +inner_tags+)
  #
  # ### Args
  #
  # * *item_id*: if of the item (lesson or element)
  # * *kind*: 'Lesson' or 'MediaElement'
  #
  # ### Returns
  #
  # A set of tags
  #
  def self.get_tags_for_item(item_id, kind)
    resp = []
    Tagging.includes(:tag).where(:taggable_type => kind, :taggable_id => item_id).order(:tag_id).each do |t|
      resp << t.tag
    end
    resp
  end
  
  # ### Description
  #
  # Used as support for Lesson#tags and MediaElement#tags
  #
  # ### Args
  #
  # * *item*: item (lesson or element)
  #
  # ### Returns
  #
  # A string of tags in the shape ',tag1,tag2,tag3,tag4,'
  #
  def self.get_friendly_tags(item)
    tags = item.taggings.order(:tag_id)
    return '' if tags.empty?
    ([''] + (tags.map { |t| t.tag.word }) + ['']).join(',')
  end
  
  # ### Description
  #
  # Setter method for the field +word+: it automatically turns the word to downcase without initial and last spaces
  #
  # ### Args
  #
  # * *word*: the word to be converted
  #
  def word=(word)
    write_attribute(:word, word.present? ? word.to_s.strip.mb_chars.downcase.to_s : word)
  end
  
  # ### Description
  #
  # Returns the word
  #
  def to_s
    word.to_s
  end
  
  # ### Description
  #
  # Gets the lessons associated to this tag through Tagging. Used in the administrator section (see Admin::SettingsController#lessons_for_tag)
  #
  # ### Args
  #
  # * *page*: the requested page
  #
  # ### Returns
  #
  # An array of tags
  #
  def get_lessons(page)
    Lesson.joins(:taggings).where(:taggings => {:tag_id => self.id}).order('lessons.updated_at DESC').page(page)
  end
  
  # ### Description
  #
  # Gets the media elements associated to this tag through Tagging. Used in the administrator section (see Admin::SettingsController#media_elements_for_tag)
  #
  # ### Args
  #
  # * *page*: the requested page
  #
  # ### Returns
  #
  # An array of tags
  #
  def get_media_elements(page)
    MediaElement.joins(:taggings).where(:taggings => {:tag_id => self.id}).order('media_elements.updated_at DESC').page(page)
  end
  
  private
  
  # Initializes validation objects (see Valid.get_association)
  def init_validation
    @tag = Valid.get_association self, :id
  end
  
  # Validates that if not new record +word+ can't be changed
  def word_not_changed
    errors.add(:word, :cant_be_changed) if @tag && @tag.word != self.word
  end
  
  # Callback that destroys the taggings before the destruction of the present tag
  def destroy_taggings
    Tagging.where(:tag_id => self.id).each do |tagging|
      tagging.not_orphans = true
      tagging.destroy
    end
  end
  
end

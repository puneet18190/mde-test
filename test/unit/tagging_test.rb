require 'test_helper'

class TaggingTest < ActiveSupport::TestCase
  
  def setup
    @tag = Tag.new
    @tag.word = 'varano di komodo'
    @tag.save
    @tagging = Tagging.new
    @tagging.tag_id = @tag.id
    @tagging.taggable_id = 2
    @tagging.taggable_type = 'MediaElement'
  end
  
  test 'tags_and_taggings_in_fixtures' do
    assert_equal 8, Tag.count
    assert_equal 32, Tagging.count
  end
  
  test 'empty_and_defaults' do
    @tagging = Tagging.new
    assert_error_size 6, @tagging
  end
  
  test 'types' do
    assert_invalid @tagging, :tag_id, 'rt', @tag.id, :not_a_number
    assert_invalid @tagging, :tag_id, 9.9, @tag.id, :not_an_integer
    assert_invalid @tagging, :taggable_id, -8, 2, :greater_than, {:count => 0}
    assert_invalid @tagging, :taggable_type, 'MidiaElement', 'MediaElement', :inclusion
    assert_obj_saved @tagging
  end
  
  test 'association_methods' do
    assert_nothing_raised {@tagging.tag}
    assert_nothing_raised {@tagging.taggable}
  end
  
  test 'uniqueness' do
    @tagging.tag_id = 3
    assert_invalid @tagging, :taggable_id, 1, 2, :taken
    @tagging.taggable_type = 'Lesson'
    @tagging.tag_id = 5
    assert_invalid @tagging, :taggable_id, 1, 2, :taken
    assert_obj_saved @tagging
  end
  
  test 'associations' do
    assert_invalid @tagging, :tag_id, 1000, @tag.id, :doesnt_exist
    assert_invalid @tagging, :taggable_id, 1000, 2, :media_element_doesnt_exist
    @tagging.taggable_type = 'Lesson'
    assert_invalid @tagging, :taggable_id, 1000, 2, :lesson_doesnt_exist
    assert_obj_saved @tagging
  end
  
  test 'impossible_changes' do
    assert_obj_saved @tagging
    assert_invalid @tagging, :tag_id, 2, @tag.id, :cant_be_changed
    assert_invalid @tagging, :taggable_id, 3, 2, :cant_be_changed
    assert_invalid @tagging, :taggable_type, 'Lesson', 'MediaElement', :cant_be_changed
    assert_obj_saved @tagging
  end
  
end

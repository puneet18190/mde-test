require 'test_helper'

class BookmarkTest < ActiveSupport::TestCase
  
  def setup
    @lesson = Lesson.new :subject_id => 1, :school_level_id => 2, :title => 'Fernandello mio', :description => 'Voglio divenire uno scienziaaato'
    @lesson.copied_not_modified = false
    @lesson.user_id = 2
    @lesson.tags = 'ciao, come, stai, tu?'
    @lesson.save
    @lesson.is_public = true
    @lesson.save
    @bookmark = Bookmark.new
    @bookmark.user_id = 1
    @bookmark.bookmarkable_type = 'Lesson'
    @bookmark.bookmarkable_id = @lesson.id
  end
  
  test 'empty_and_defaults' do
    @bookmark = Bookmark.new
    assert_error_size 6, @bookmark
  end
  
  test 'types' do
    assert_invalid @bookmark, :user_id, 'rt', 1, :not_a_number
    assert_invalid @bookmark, :user_id, 9.9, 1, :not_an_integer
    assert_invalid @bookmark, :bookmarkable_id, -8, @lesson.id, :greater_than, {:count => 0}
    assert_invalid @bookmark, :bookmarkable_type, 'Lessen', 'Lesson', :inclusion
    assert_obj_saved @bookmark
  end
  
  test 'association_methods' do
    assert_nothing_raised {@bookmark.user}
    assert_nothing_raised {@bookmark.bookmarkable}
  end
  
  test 'uniqueness' do
    assert_invalid @bookmark, :bookmarkable_id, 2, @lesson.id, :taken
    @bookmark.bookmarkable_type = 'MediaElement'
    @bookmark.user_id = 2
    assert_invalid @bookmark, :bookmarkable_id, 4, 6, :taken
    assert_obj_saved @bookmark
  end
  
  test 'associations' do
    assert_invalid @bookmark, :user_id, 1000, 1, :doesnt_exist
    assert_invalid @bookmark, :bookmarkable_id, 1000, @lesson.id, :lesson_doesnt_exist
    assert_obj_saved @bookmark
    @bookmark = Bookmark.find 2
    assert_invalid @bookmark, :bookmarkable_id, 1000, 4, :media_element_doesnt_exist
    assert_obj_saved @bookmark
  end
  
  test 'impossible_changes' do
    assert_obj_saved @bookmark
    @bookmark.user_id = 2
    assert !@bookmark.save, "Bookmark erroneously saved - #{@bookmark.inspect}"
    assert_equal 2, @bookmark.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@bookmark.errors.inspect}"
    assert_equal 2, @bookmark.errors.size
    assert @bookmark.errors.added? :user_id, :cant_be_changed
    @bookmark.user_id = 1
    assert @bookmark.valid?, "Bookmark not valid: #{@bookmark.errors.inspect}"
    @bookmark.bookmarkable_id = 2
    assert !@bookmark.save, "Bookmark erroneously saved - #{@bookmark.inspect}"
    assert_equal 1, @bookmark.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@bookmark.errors.inspect}"
    assert @bookmark.errors.added? :bookmarkable_id, :cant_be_changed
    @bookmark.bookmarkable_id = @lesson.id
    assert @bookmark.valid?, "Bookmark not valid: #{@bookmark.errors.inspect}"
    @bookmark.bookmarkable_type = 'MediaElement'
    assert !@bookmark.save, "Bookmark erroneously saved - #{@bookmark.inspect}"
    assert_equal 2, @bookmark.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@bookmark.errors.inspect}"
    assert_equal 2, @bookmark.errors.size
    assert @bookmark.errors.added? :bookmarkable_type, :cant_be_changed
    @bookmark.bookmarkable_type = 'Lesson'
    assert @bookmark.valid?, "Bookmark not valid: #{@bookmark.errors.inspect}"
    assert_obj_saved @bookmark
  end
  
  test 'availability' do
    assert_invalid @bookmark, :bookmarkable_id, 1, @lesson.id, :lesson_not_available_for_bookmarks
    @lesson.is_public = false
    assert_obj_saved @lesson
    assert !@bookmark.save, "Bookmark erroneously saved - #{@bookmark.inspect}"
    assert_equal 1, @bookmark.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@bookmark.errors.inspect}"
    assert_equal 1, @bookmark.errors.size
    assert @bookmark.errors.added? :bookmarkable_id, :lesson_not_available_for_bookmarks
    @lesson.is_public = true
    assert_obj_saved @lesson
    assert @bookmark.valid?, "Bookmark not valid: #{@bookmark.errors.inspect}"
    @bookmark.bookmarkable_type = 'MediaElement'
    assert_invalid @bookmark, :bookmarkable_id, 1, 2, :media_element_not_available_for_bookmarks
    assert_invalid @bookmark, :bookmarkable_id, 3, 6, :media_element_not_available_for_bookmarks
    assert_obj_saved @bookmark
  end
  
end

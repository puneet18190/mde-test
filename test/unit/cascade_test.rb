require 'test_helper'

class CascadeTest < ActiveSupport::TestCase
  
  test 'mailing_list_cascade' do
    resp = User.confirmed.new(:password => '12345678', :password_confirmation => '12345678', :name => 'oo', :surname => 'fsg', :school_level_id => 1, :location_id => 1, :subject_ids => [1, 2]) do |user|
      user.email = SETTINGS['super_admin']
    end
    resp.policy_1 = '1'
    resp.policy_2 = '1'
    resp.active = true
    assert_obj_saved resp
    mg1 = MailingListGroup.new
    mg1.user_id = 1
    mg1.name = 'Gruppo 1'
    assert_obj_saved mg1
    mg2 = MailingListGroup.new
    mg2.user_id = 1
    mg2.name = 'Gruppo 2'
    assert_obj_saved mg2
    mg1 = mg1.id
    mg2 = mg2.id
    address1 = MailingListAddress.new
    address1.group_id = mg1
    address1.heading = 'cane'
    address1.email = 'cane@cane.cn'
    assert_obj_saved address1
    address2 = MailingListAddress.new
    address2.group_id = mg2
    address2.heading = 'Pinilla'
    address2.email = 'pinilla@cane.cn'
    assert_obj_saved address1
    address1 = address1.id
    address2 = address2.id
    MailingListGroup.find(mg2).destroy
    assert_nil MailingListGroup.find_by_id mg2
    assert_nil MailingListAddress.find_by_id address2
    assert_not_nil MailingListGroup.find_by_id mg1
    assert_not_nil MailingListAddress.find_by_id address1
    assert_not_nil Document.find_by_id 1
    User.find(1).destroy_with_dependencies
    assert_nil User.find_by_id 1
    assert_nil MailingListGroup.find_by_id mg1
    assert_nil Document.find_by_id 1
    assert_nil MailingListAddress.find_by_id address1
  end
  
  test 'lesson_cascade' do
    assert_equal 2, DocumentsSlide.count
    @lesson = Lesson.find 2
    @copied_lesson = Lesson.new :subject_id => 1, :school_level_id => 2, :title => 'Fernandello mio', :description => 'Voglio divenire uno scienziaaato'
    @copied_lesson.copied_not_modified = false
    @copied_lesson.user_id = 1
    @copied_lesson.parent_id = 2
    @copied_lesson.tags = 'a, b, c, topolino'
    @copied_lesson.save_tags = true
    assert_obj_saved @copied_lesson
    assert_nil Tag.find_by_word('pippo')
    assert_nil Tag.find_by_word('pluto')
    assert_nil Tag.find_by_word('paperino')
    assert_not_nil Tag.find_by_word('topolino')
    @lesson.tags = 'pippo, pluto, paperino, topolino'
    @lesson.save_tags = true
    assert_obj_saved @lesson
    assert_not_nil Tag.find_by_word('topolino')
    assert_not_nil Tag.find_by_word('pippo')
    assert_not_nil Tag.find_by_word('pluto')
    assert_not_nil Tag.find_by_word('paperino')
    @lesson = Lesson.find @lesson.id
    ids = {Bookmark => [], Like => [], Slide => [], MediaElementsSlide => [], Tagging => [], Report => [], VirtualClassroomLesson => []}
    assert_equal @lesson.id, @copied_lesson.parent.id
    assert_equal 1, @lesson.bookmarks.length
    @lesson.bookmarks.each do |b|
      ids[Bookmark] << b.id
    end
    assert_equal 1, @lesson.likes.length
    @lesson.likes.each do |b|
      ids[Like] << b.id
    end
    assert_equal 3, @lesson.slides.length
    @lesson.slides.each do |b|
      ids[Slide] << b.id
    end
    @lesson.slides.where(:id => [3, 4]).each do |s|
      assert_equal 1, s.media_elements_slides.length
      s.media_elements_slides.each do |b|
        ids[MediaElementsSlide] << b.id
      end
    end
    assert_equal 4, @lesson.taggings.length
    @lesson.taggings.each do |b|
      ids[Tagging] << b.id
    end
    assert_equal 2, @lesson.reports.length
    @lesson.reports.each do |b|
      ids[Report] << b.id
    end
    assert_equal 1, @lesson.virtual_classroom_lessons.length
    @lesson.virtual_classroom_lessons.each do |b|
      ids[VirtualClassroomLesson] << b.id
    end
    @lesson.destroy
    assert Lesson.find(@copied_lesson.id).parent_id.nil?
    assert Lesson.where(:id => @lesson.id).empty?
    ids.each do |k, v|
      assert k.where(:id => v).empty?, "Error, #{k.to_s} not deleted -- #{k.where(:id => v).inspect}"
    end
    assert_nil Tag.find_by_word('pippo')
    assert_nil Tag.find_by_word('pluto')
    assert_nil Tag.find_by_word('paperino')
    assert_not_nil Tag.find_by_word('topolino')
    assert DocumentsSlide.all.empty?
    new_slisli = Lesson.find(1).add_slide('text', 2)
    assert_not_nil new_slisli
    x = DocumentsSlide.new
    x.document_id = 1
    x.slide_id = new_slisli.id
    assert_obj_saved x
    assert_equal 1, DocumentsSlide.all.count
    Document.find(1).destroy
    assert_equal 0, DocumentsSlide.count
  end
  
  test 'media_element_cascade' do
    @media_element = MediaElement.find 1
    l = Lesson.find(1)
    slide = l.add_slide 'video1', 2
    assert !slide.nil?
    @media_elements_slide = MediaElementsSlide.new
    @media_elements_slide.slide_id = slide.id
    @media_elements_slide.media_element_id = 1
    @media_elements_slide.position = 1
    assert_obj_saved @media_elements_slide
    @media_element = MediaElement.find @media_element.id
    ids = {Tagging => [], Report => [], MediaElementsSlide => []}
    assert_equal 4, @media_element.taggings.length
    @media_element.taggings.each do |l|
      ids[Tagging] << l.id
    end
    assert_equal 1, @media_element.reports.length
    @media_element.reports.each do |l|
      ids[Report] << l.id
    end
    assert_equal 1, @media_element.media_elements_slides.length
    @media_element.media_elements_slides.each do |l|
      ids[MediaElementsSlide] << l.id
    end
    assert ids[MediaElementsSlide].any?
    @media_element.destroy
    assert MediaElement.where(:id => @media_element.id).empty?
    ids.each do |k, v|
      assert k.where(:id => v).empty?, "Error, #{k.to_s} not deleted -- #{k.where(:id => v).inspect}"
    end
  end
  
  test 'lesson_bookmarks_cascade' do
    @bookmark = Bookmark.find 1
    assert_equal 'Lesson', @bookmark.bookmarkable_type
    assert_equal 1, VirtualClassroomLesson.where(:user_id => @bookmark.user_id, :lesson_id => @bookmark.bookmarkable_id).length
    id = VirtualClassroomLesson.where(:user_id => @bookmark.user_id, :lesson_id => @bookmark.bookmarkable_id).first.id
    @bookmark.destroy
    assert Bookmark.where(:id => 1).empty?
    assert VirtualClassroomLesson.where(:id => id).empty?
  end
  
  test 'lesson_bookmarks_cascade_without_virtual_classroom' do
    @bookmark = Bookmark.find 1
    assert_equal 'Lesson', @bookmark.bookmarkable_type
    vc = VirtualClassroomLesson.where(:user_id => @bookmark.user_id, :lesson_id => @bookmark.bookmarkable_id).first
    assert !vc.nil?
    vc.destroy
    assert VirtualClassroomLesson.where(:user_id => @bookmark.user_id, :lesson_id => @bookmark.bookmarkable_id).empty?
    @bookmark.destroy
    assert Bookmark.where(:id => 1).empty?
  end
  
  test 'tag_cascade' do
    x = Tag.new
    x.word = 'ruby'
    assert_obj_saved x
    tagging1 = Tagging.new
    tagging1.taggable_type = 'MediaElement'
    tagging1.taggable_id = 1
    tagging1.tag_id = x.id
    assert_obj_saved tagging1
    tagging2 = Tagging.new
    tagging2.taggable_type = 'Lesson'
    tagging2.taggable_id = 1
    tagging2.tag_id = x.id
    assert_obj_saved tagging2
    tag_id = x.id
    tagging_ids = [tagging1.id, tagging2.id]
    x.destroy
    assert Tag.find_by_id(tag_id).nil?
    assert Tagging.where(:id => tagging_ids).empty?
  end
  
end

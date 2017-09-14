require 'test_helper'

class VirtualClassroomLessonTest < ActiveSupport::TestCase
  
  def setup
    @lesson = Lesson.new :subject_id => 1, :school_level_id => 2, :title => 'Fernandello mio', :description => 'Voglio divenire uno scienziaaato'
    @lesson.copied_not_modified = false
    @lesson.user_id = 2
    @lesson.tags = 'topolino, pippo, pluto, paperino'
    @lesson.save
    @virtual_classroom_lesson = VirtualClassroomLesson.new :position => nil
    @virtual_classroom_lesson.user_id = 2
    @virtual_classroom_lesson.lesson_id = @lesson.id
  end
  
  test 'empty_and_defaults' do
    @virtual_classroom_lesson = VirtualClassroomLesson.new
    assert_error_size 6, @virtual_classroom_lesson
  end
  
  test 'types' do
    assert_invalid @virtual_classroom_lesson, :user_id, 'ty', 2, :not_a_number
    assert_invalid @virtual_classroom_lesson, :user_id, -1, 2, :greater_than, {:count => 0}
    assert_invalid @virtual_classroom_lesson, :lesson_id, 1.5, @lesson.id, :not_an_integer
    assert_invalid @virtual_classroom_lesson, :position, 'iii', nil, :not_a_number
    assert_invalid @virtual_classroom_lesson, :position, -5, nil, :greater_than, {:count => 0}
    assert_invalid @virtual_classroom_lesson, :position, 1.5, nil, :not_an_integer
    assert_obj_saved @virtual_classroom_lesson
  end
  
  test 'association_methods' do
    assert_nothing_raised {@virtual_classroom_lesson.user}
    assert_nothing_raised {@virtual_classroom_lesson.lesson}
  end
  
  test 'associations' do
    assert_invalid @virtual_classroom_lesson, :user_id, 1000, 2, :doesnt_exist
    assert_invalid @virtual_classroom_lesson, :lesson_id, 1000, @lesson.id, :doesnt_exist
    assert_obj_saved @virtual_classroom_lesson
  end
  
  test 'uniqueness' do
    # I test uniqueness of presence in virtualclassroom
    @virtual_classroom_lesson.user_id = 1
    @virtual_classroom_lesson.lesson_id = 2
    assert !@virtual_classroom_lesson.save, "VirtualClassroomLesson erroneously saved - #{@virtual_classroom_lesson.inspect}"
    assert_equal 1, @virtual_classroom_lesson.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@virtual_classroom_lesson.errors.inspect}"
    assert_equal 1, @virtual_classroom_lesson.errors.size
    assert @virtual_classroom_lesson.errors.added? :lesson_id, :taken
    @virtual_classroom_lesson.lesson_id = @lesson.id
    @virtual_classroom_lesson.user_id = 2
    assert @virtual_classroom_lesson.valid?, "VirtualClassroomLesson not valid: #{@virtual_classroom_lesson.errors.inspect}"
    # I create a bookmark for the lesson created here (I make it public first) to user id = 1
    @lesson.is_public = true
    assert_obj_saved @lesson
    @bookmark = Bookmark.new
    @bookmark.user_id = 1
    @bookmark.bookmarkable_id = @lesson.id
    @bookmark.bookmarkable_type = 'Lesson'
    assert_obj_saved @bookmark
    @virtual_classroom_lesson.user_id = 1
    assert_equal @lesson.id, @virtual_classroom_lesson.lesson_id
    assert_obj_saved @virtual_classroom_lesson
    @virtual_classroom_lesson.position = 1
    assert !@virtual_classroom_lesson.save, "VirtualClassroomLesson erroneously saved - #{@virtual_classroom_lesson.inspect}"
    assert_equal 1, @virtual_classroom_lesson.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@virtual_classroom_lesson.errors.inspect}"
    assert_equal 1, @virtual_classroom_lesson.errors.size
    assert @virtual_classroom_lesson.errors.added? :position, :taken
    @virtual_classroom_lesson.position = 2
    assert @virtual_classroom_lesson.valid?, "VirtualClassroomLesson not valid: #{@virtual_classroom_lesson.errors.inspect}"
    assert_obj_saved @virtual_classroom_lesson
  end
  
  test 'availability' do
    assert_invalid @virtual_classroom_lesson, :lesson_id, 1, @lesson.id, :is_not_available
    lesson1 = Lesson.find(1)
    assert !lesson1.is_public
    lesson1.is_public = true
    assert_obj_saved lesson1
    assert_invalid @virtual_classroom_lesson, :lesson_id, 1, @lesson.id, :is_not_available
    assert_obj_saved @virtual_classroom_lesson
  end
  
  test 'copied_not_modified' do
    @lesson.copied_not_modified = true
    assert_obj_saved @lesson
    assert !@virtual_classroom_lesson.save, "VirtualClassroomLesson erroneously saved - #{@virtual_classroom_lesson.inspect}"
    assert_equal 1, @virtual_classroom_lesson.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@virtual_classroom_lesson.errors.inspect}"
    assert_equal 1, @virtual_classroom_lesson.errors.size
    assert @virtual_classroom_lesson.errors.added? :lesson_id, :just_been_copied
    @lesson.copied_not_modified = false
    assert_obj_saved @lesson
    assert @virtual_classroom_lesson.valid?, "VirtualClassroomLesson not valid: #{@virtual_classroom_lesson.errors.inspect}"
  end
  
  test 'positions' do
    assert_invalid @virtual_classroom_lesson, :position, 1, nil, :must_be_null_if_new_record
    assert_obj_saved @virtual_classroom_lesson
  end
  
  test 'impossible_changes' do
    assert_obj_saved @virtual_classroom_lesson
    @virtual_classroom_lesson.user_id = 1
    assert !@virtual_classroom_lesson.save, "VirtualClassroomLesson erroneously saved - #{@virtual_classroom_lesson.inspect}"
    assert_equal 2, @virtual_classroom_lesson.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@virtual_classroom_lesson.errors.inspect}"
    assert_equal 2, @virtual_classroom_lesson.errors.size
    assert @virtual_classroom_lesson.errors.added? :user_id, :cant_be_changed
    @virtual_classroom_lesson.user_id = 2
    assert @virtual_classroom_lesson.valid?, "VirtualClassroomLesson not valid: #{@virtual_classroom_lesson.errors.inspect}"
    assert_invalid @virtual_classroom_lesson, :lesson_id, 1, @lesson.id, :cant_be_changed
    assert_obj_saved @virtual_classroom_lesson
  end
  
  test 'playlist_size' do
    Lesson.where(:user_id => 1).each do |l|
      l.destroy
    end
    VirtualClassroomLesson.where(:user_id => 1).each do |vcl|
      vcl.destroy
    end
    assert Lesson.where(:user_id => 1).empty?
    assert VirtualClassroomLesson.where(:user_id => 1).empty?
    user = User.find 1
    (0...20).each do |i|
      x = user.create_lesson "title_#{i}", "description_#{i}", 1, 'paperino, pippo, pluto, topolino'
      assert x
      assert x.add_to_virtual_classroom 1
      vc = VirtualClassroomLesson.where(:user_id => 1, :lesson_id => x.id).first
      assert vc.add_to_playlist, "Failed adding to playlist the lesson #{vc.lesson.inspect}"
    end
    assert_equal 20, Lesson.where(:user_id => 1).count
    assert_equal 20, VirtualClassroomLesson.where(:user_id => 1).count
    assert_equal 20, user.playlist.length
    x = user.create_lesson "title_20", "description_20", 1, 'paperino, pippo, pluto, topolino'
    assert x
    assert x.add_to_virtual_classroom 1
    vc = VirtualClassroomLesson.where(:user_id => 1, :lesson_id => x.id).first
    assert vc.position.nil?
    assert_invalid vc, :position, 21, nil, :reached_maximum_in_playlist
    assert_obj_saved vc
  end
  
  test 'playlist_for_viewer' do
    @user1 = User.find(1)
    @les1 = Lesson.find(1)
    @les2 = Lesson.find(2)
    @les3 = @user1.create_lesson('title3', 'desc3', 3, 'cane, gatto, topo, aragosta')
    @les4 = @user1.create_lesson('title4', 'desc4', 3, 'cane, gatto, topo, aragosta')
    @les5 = @user1.create_lesson('title5', 'desc5', 3, 'cane, gatto, topo, aragosta')
    @les6 = @user1.create_lesson('title6', 'desc6', 3, 'cane, gatto, topo, aragosta')
    @les7 = @user1.create_lesson('title7', 'desc7', 3, 'cane, gatto, topo, aragosta')
    @les8 = @user1.create_lesson('title8', 'desc8', 3, 'cane, gatto, topo, aragosta')
    @les9 = @user1.create_lesson('title9', 'desc9', 3, 'cane, gatto, topo, aragosta')
    assert @les3.kind_of?(Lesson)
    assert @les4.kind_of?(Lesson)
    assert @les5.kind_of?(Lesson)
    assert @les6.kind_of?(Lesson)
    assert @les7.kind_of?(Lesson)
    assert @les8.kind_of?(Lesson)
    assert @les9.kind_of?(Lesson)
    assert @les1.add_to_virtual_classroom(1)
    assert_equal 1, VirtualClassroomLesson.where(:user_id => 1, :lesson_id => 2).count
    assert @les3.add_to_virtual_classroom(1)
    assert @les4.add_to_virtual_classroom(1)
    assert @les5.add_to_virtual_classroom(1)
    assert @les6.add_to_virtual_classroom(1)
    assert @les7.add_to_virtual_classroom(1)
    assert @les8.add_to_virtual_classroom(1)
    assert @les9.add_to_virtual_classroom(1)
    VirtualClassroomLesson.where(:user_id => 1, :lesson_id => [@les4.id, @les7.id]).update_all(:user_id => 2)
    assert_equal 7, VirtualClassroomLesson.where(:user_id => 1).count
    VirtualClassroomLesson.where('user_id = 1 AND id != 1').each_with_index do |vcl, i|
      vcl.position = i + 2
      assert_obj_saved vcl
    end
    assert VirtualClassroomLesson.where(:lesson_id => @les8.id).first.remove_from_playlist
    assert VirtualClassroomLesson.where(:lesson_id => @les3.id).first.remove_from_playlist
    assert VirtualClassroomLesson.where(:lesson_id => @les2.id).first.change_position(4)
    assert VirtualClassroomLesson.where(:lesson_id => @les6.id).first.change_position(1)
    playlist = VirtualClassroomLesson.where('position IS NOT NULL AND user_id = 1').order('position ASC')
    assert_equal 5, playlist.length
    @vcl1 = VirtualClassroomLesson.where(:user_id => 1, :lesson_id => @les1.id).first
    @vcl2 = VirtualClassroomLesson.where(:user_id => 1, :lesson_id => @les2.id).first
    @vcl5 = VirtualClassroomLesson.where(:user_id => 1, :lesson_id => @les5.id).first
    @vcl6 = VirtualClassroomLesson.where(:user_id => 1, :lesson_id => @les6.id).first
    @vcl9 = VirtualClassroomLesson.where(:user_id => 1, :lesson_id => @les9.id).first
    assert_equal @vcl6.id, playlist[0].id
    assert_equal @vcl1.id, playlist[1].id
    assert_equal @vcl5.id, playlist[2].id
    assert_equal @vcl2.id, playlist[3].id
    assert_equal @vcl9.id, playlist[4].id
    assert (@vcl1.id < @vcl6.id) && (@vcl2.id < @vcl5.id) && (@vcl2.id < @vcl9.id) && (@vcl1.id < @vcl5.id)
    @les1 = Lesson.find @les1.id
    @les2 = Lesson.find @les2.id
    @les3 = Lesson.find @les3.id
    @les4 = Lesson.find @les4.id
    @les5 = Lesson.find @les5.id
    @les6 = Lesson.find @les6.id
    @les7 = Lesson.find @les7.id
    @les8 = Lesson.find @les8.id
    @les9 = Lesson.find @les9.id
    # slides of lesson 1
    assert_equal 1, @les1.slides.length
    @slide_1_1 = @les1.cover
    # slides of lesson 2
    assert_equal 3, @les2.slides.length
    @slide_2_1 = @les2.cover
    @slide_2_2 = Slide.where(:lesson_id => @les2.id, :position => 2).first
    @slide_2_3 = Slide.where(:lesson_id => @les2.id, :position => 3).first
    # slides of lesson 5
    @slide_5_1 = @les5.cover
    @slide_5_2 = @les5.add_slide 'text', 2
    assert_not_nil @slide_5_2
    @slide_5_3 = @les5.add_slide 'title', 3
    assert_not_nil @slide_5_3
    @slide_5_4 = @les5.add_slide 'audio', 4
    assert_not_nil @slide_5_4
    assert @slide_5_4.change_position(2)
    # slides of lesson 6
    @slide_6_1 = @les6.cover
    # slides of lesson 9
    @slide_9_1 = @les9.cover
    @slide_9_2 = @les9.add_slide 'video2', 2
    assert_not_nil @slide_9_2
    @slide_9_3 = @les9.add_slide 'image3', 3
    assert_not_nil @slide_9_3
    # covers not included in the playlist
    @cover7 = @les7.cover
    @cover8 = @les8.cover
    # extract now!
    resp = User.find(1).playlist_for_viewer
    assert_equal 12, resp.length
    assert_equal @slide_6_1.id, resp[0].id
    assert_equal @slide_1_1.id, resp[1].id
    assert_equal @slide_5_1.id, resp[2].id
    assert_equal @slide_5_4.id, resp[3].id
    assert_equal @slide_5_2.id, resp[4].id
    assert_equal @slide_5_3.id, resp[5].id
    assert_equal @slide_2_1.id, resp[6].id
    assert_equal @slide_2_2.id, resp[7].id
    assert_equal @slide_2_3.id, resp[8].id
    assert_equal @slide_9_1.id, resp[9].id
    assert_equal @slide_9_2.id, resp[10].id
    assert_equal @slide_9_3.id, resp[11].id
    # slides not included
    resp.each do |r|
      assert ![@cover7.id, @cover8.id].include?(r.id)
    end
  end
  
end

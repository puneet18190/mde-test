# encoding: UTF-8

require 'test_helper'

class StatisticsTest < ActiveSupport::TestCase
  
  def load_likers
    @liker1 = User.confirmed.new(:password => 'em1@em.em', :password_confirmation => 'em1@em.em', :name => 'dgdsg', :surname => 'sdgds', :school_level_id => 1, :location_id => 1, :subject_ids => [1]) do |user|
      user.email = 'em1@em.em'
      user.active = true
    end
    @liker1.policy_1 = '1'
    @liker1.policy_2 = '1'
    assert @liker1.save
    @liker2 = User.confirmed.new(:password => 'em2@em.em', :password_confirmation => 'em2@em.em', :name => 'dgdsg', :surname => 'sdgds', :school_level_id => 1, :location_id => 1, :subject_ids => [1]) do |user|
      user.email = 'em2@em.em'
      user.active = true
    end
    @liker2.policy_1 = '1'
    @liker2.policy_2 = '1'
    assert @liker2.save
    @liker3 = User.confirmed.new(:password => 'em3@em.em', :password_confirmation => 'em3@em.em', :name => 'dgdsg', :surname => 'sdgds', :school_level_id => 1, :location_id => 1, :subject_ids => [1]) do |user|
      user.email = 'em3@em.em'
      user.active = true
    end
    @liker3.policy_1 = '1'
    @liker3.policy_2 = '1'
    assert @liker3.save
    @liker4 = User.confirmed.new(:password => 'em4@em.em', :password_confirmation => 'em4@em.em', :name => 'dgdsg', :surname => 'sdgds', :school_level_id => 1, :location_id => 1, :subject_ids => [1]) do |user|
      user.email = 'em4@em.em'
      user.active = true
    end
    @liker4.policy_1 = '1'
    @liker4.policy_2 = '1'
    assert @liker4.save
    @liker5 = User.confirmed.new(:password => 'em5@em.em', :password_confirmation => 'em5@em.em', :name => 'dgdsg', :surname => 'sdgds', :school_level_id => 1, :location_id => 1, :subject_ids => [1]) do |user|
      user.email = 'em5@em.em'
      user.active = true
    end
    @liker5.policy_1 = '1'
    @liker5.policy_2 = '1'
    assert @liker5.save
    @liker6 = User.confirmed.new(:password => 'em6@em.em', :password_confirmation => 'em6@em.em', :name => 'dgdsg', :surname => 'sdgds', :school_level_id => 1, :location_id => 1, :subject_ids => [1]) do |user|
      user.email = 'em6@em.em'
      user.active = true
    end
    @liker6.policy_1 = '1'
    @liker6.policy_2 = '1'
    assert @liker6.save
    @liker7 = User.confirmed.new(:password => 'em7@em.em', :password_confirmation => 'em7@em.em', :name => 'dgdsg', :surname => 'sdgds', :school_level_id => 1, :location_id => 1, :subject_ids => [1]) do |user|
      user.email = 'em7@em.em'
      user.active = true
    end
    @liker7.policy_1 = '1'
    @liker7.policy_2 = '1'
    assert @liker7.save
    @liker8 = User.confirmed.new(:password => 'em8@em.em', :password_confirmation => 'em8@em.em', :name => 'dgdsg', :surname => 'sdgds', :school_level_id => 1, :location_id => 1, :subject_ids => [1]) do |user|
      user.email = 'em8@em.em'
      user.active = true
    end
    @liker8.policy_1 = '1'
    @liker8.policy_2 = '1'
    assert @liker8.save
    @liker9 = User.confirmed.new(:password => 'em9@em.em', :password_confirmation => 'em9@em.em', :name => 'dgdsg', :surname => 'sdgds', :school_level_id => 1, :location_id => 1, :subject_ids => [1]) do |user|
      user.email = 'em9@em.em'
      user.active = true
    end
    @liker9.policy_1 = '1'
    @liker9.policy_2 = '1'
    assert @liker9.save
  end
  
  def load_likes
    Like.all.each do |l|
      l.destroy
    end
    assert @liker1.like @les1.id
    assert @liker1.like @les3.id
    assert @liker1.like @les6.id
    assert @liker1.like @les9.id
    assert @liker2.like @les2.id
    assert @liker2.like @les3.id
    assert @liker2.like @les4.id
    assert @liker2.like @les7.id
    assert @liker3.like @les1.id
    assert @liker4.like @les4.id
    assert @liker4.like @les8.id
    assert @liker5.like @les5.id
    assert @liker5.like @les6.id
    assert @liker5.like @les7.id
    assert @liker6.like @les8.id
    assert @liker6.like @les1.id
    assert @liker6.like @les3.id
    assert @liker7.like @les1.id
    assert @liker7.like @les5.id
    assert @liker7.like @les6.id
    assert @liker8.like @les8.id
    assert @liker9.like @les8.id
    assert @liker9.like @les1.id
  end
  
  def load_items
    @user1 = User.find 1
    @user1.name = 'a_name'
    @user1.surname = 'a_surname'
    assert_obj_saved @user1
    us_sub_1_2 = UsersSubject.new
    us_sub_1_2.user_id = 1
    us_sub_1_2.subject_id = 2
    assert_obj_saved us_sub_1_2
    us_sub_1_4 = UsersSubject.new
    us_sub_1_4.user_id = 1
    us_sub_1_4.subject_id = 4
    assert_obj_saved us_sub_1_4
    us_sub_1_5 = UsersSubject.new
    us_sub_1_5.user_id = 1
    us_sub_1_5.subject_id = 5
    assert_obj_saved us_sub_1_5
    us_sub_1_6 = UsersSubject.new
    us_sub_1_6.user_id = 1
    us_sub_1_6.subject_id = 6
    assert_obj_saved us_sub_1_6
    @user2 = User.find 2
    @user2.name = 'a_name'
    @user2.surname = 'a_surname'
    assert_obj_saved @user2
    us_sub_2_2 = UsersSubject.new
    us_sub_2_2.user_id = 2
    us_sub_2_2.subject_id = 2
    assert_obj_saved us_sub_2_2
    us_sub_2_3 = UsersSubject.new
    us_sub_2_3.user_id = 2
    us_sub_2_3.subject_id = 3
    assert_obj_saved us_sub_2_3
    us_sub_2_4 = UsersSubject.new
    us_sub_2_4.user_id = 2
    us_sub_2_4.subject_id = 4
    assert_obj_saved us_sub_2_4
    @user1 = User.find 1
    @user2 = User.find 2
    Tagging.all.each do |t|
      ActiveRecord::Base.connection.execute "DELETE FROM taggings WHERE id = #{t.id}"
    end
    Tag.all.each do |t|
      t.destroy
    end
    tag_map = {
      0 => "cane, sole, togatto, cincillà, walter nudo, luna, di escrementi di usignolo",
      1 => "walter nudo, luna, di escrementi di usignolo, disabili, torriere architettoniche, mare, petrolio",
      2 => "torriere architettoniche, mare, petrolio, sostenibilità, di immondizia, tonquinamento atmosferico, tonquinamento",
      3 => "tonquinamento, pollution, tom cruise, cammello, cammelli, acqua, acquario",
      4 => "cammelli, acqua, acquario, acquatico, 個名, 拿大即, 河",
      5 => "個名, 拿大即, 河, 條聖, 係英國, 拿, 住羅倫",
      6 => "係英國, 拿, 住羅倫, 加, 大湖, 咗做, 個",
      7 => "大湖, 咗做, 個, 條聖法話, cane, sole, togatto",
      8 => "togatto, luna, torriere architettoniche, sostenibilità, tonquinamento, cammello, acquario",
      9 => "di escrementi di usignolo, tonquinamento atmosferico, acquario, 拿, walter nudo, mare, tonquinamento"
    }
    me1 = MediaElement.find 1
    me1.tags = tag_map[0]
    assert_obj_saved me1
    me2 = MediaElement.find 2
    me2.tags = tag_map[1]
    assert_obj_saved me2
    me3 = MediaElement.find 3
    me3.tags = tag_map[2]
    assert_obj_saved me3
    me4 = MediaElement.find 4
    me4.tags = tag_map[3]
    assert_obj_saved me4
    me5 = MediaElement.find 5
    me5.tags = tag_map[4]
    assert_obj_saved me5
    me6 = MediaElement.find 6
    me6.tags = tag_map[5]
    assert_obj_saved me6
    media_video = {:mp4 => Rails.root.join('test/samples/one.mp4').to_s, :webm => Rails.root.join('test/samples/one.webm').to_s, :filename => 'video_test'}
    media_audio = {:m4a => Rails.root.join('test/samples/one.m4a').to_s, :ogg => Rails.root.join('test/samples/one.ogg').to_s, :filename => 'audio_test'}
    media_image = File.open(Rails.root.join('test/samples/one.jpg'))
    @el1 = Video.new :description => 'desc1', :title => 'titl1', :media => media_video, :tags => tag_map[8]
    @el1.user_id = 1
    assert_obj_saved @el1
    @el2 = Video.new :description => 'desc2', :title => 'titl2', :media => media_video, :tags => tag_map[9]
    @el2.user_id = 1
    assert_obj_saved @el2
    @el3 = Audio.new :description => 'desc3', :title => 'titl3', :media => media_audio, :tags => tag_map[0]
    @el3.user_id = 1
    assert_obj_saved @el3
    @el4 = Audio.new :description => 'desc4', :title => 'titl4', :media => media_audio, :tags => tag_map[6]
    @el4.user_id = 1
    assert_obj_saved @el4
    @el5 = Image.new :description => 'desc5', :title => 'titl5', :media => media_image, :tags => tag_map[1]
    @el5.user_id = 1
    assert_obj_saved @el5
    @el6 = Image.new :description => 'desc6', :title => 'titl6', :media => media_image, :tags => tag_map[7]
    @el6.user_id = 1
    assert_obj_saved @el6
    @el7 = Image.new :description => 'desc7', :title => 'titl7', :media => media_image, :tags => tag_map[2]
    @el7.user_id = 1
    assert_obj_saved @el7
    le1 = Lesson.find 1
    le1.tags = tag_map[3]
    assert_obj_saved le1
    le2 = Lesson.find 2
    le2.tags = tag_map[4]
    assert_obj_saved le2
    @les1 = @user1.create_lesson('title1', 'desc1', 1, tag_map[8])
    @les2 = @user1.create_lesson('title2', 'desc2', 2, tag_map[9])
    @les3 = @user1.create_lesson('title3', 'desc3', 3, tag_map[0])
    @les4 = @user1.create_lesson('title4', 'desc4', 4, tag_map[1])
    @les5 = @user1.create_lesson('title5', 'desc5', 5, tag_map[2])
    @les6 = @user1.create_lesson('title6', 'desc6', 6, tag_map[3])
    @les7 = @user1.create_lesson('title7', 'desc7', 1, tag_map[5])
    @les8 = @user1.create_lesson('title8', 'desc8', 2, tag_map[6])
    @les9 = @user1.create_lesson('title9', 'desc9', 3, tag_map[7])
    assert_equal 11, Lesson.count, "Error, a lesson was not saved -- {les1 => #{@les1.inspect}, les2 => #{@les2.inspect}, les3 => #{@les3.inspect}, les4 => #{@les4.inspect}, les5 => #{@les5.inspect}, les6 => #{@les6.inspect}, les7 => #{@les7.inspect}, les8 => #{@les8.inspect}, les9 => #{@les9.inspect},}"
    assert @les1.publish
    assert @les2.publish
    assert @les3.publish
    assert @les4.publish
    assert @les5.publish
    assert @les6.publish
    # I SET UPDATED AT
    MediaElement.where(:id => 1).update_all(:updated_at => '2012-01-01 20:00:00')
    MediaElement.where(:id => 2).update_all(:updated_at => '2012-01-01 19:59:59')
    MediaElement.where(:id => 3).update_all(:updated_at => '2012-01-01 19:59:58')
    MediaElement.where(:id => 4).update_all(:updated_at => '2012-01-01 19:59:57')
    MediaElement.where(:id => 5).update_all(:updated_at => '2012-01-01 19:59:56')
    MediaElement.where(:id => 6).update_all(:updated_at => '2012-01-01 19:59:55')
    MediaElement.where(:id => @el1.id).update_all(:updated_at => '2011-10-01 20:00:00', :is_public => true, :publication_date => '2012-01-01 10:00:00')
    MediaElement.where(:id => @el2.id).update_all(:updated_at => '2011-10-01 19:59:59', :is_public => true, :publication_date => '2012-01-01 10:00:00')
    MediaElement.where(:id => @el3.id).update_all(:updated_at => '2011-10-01 19:59:58', :is_public => true, :publication_date => '2012-01-01 10:00:00')
    MediaElement.where(:id => @el4.id).update_all(:updated_at => '2011-10-01 19:59:57')
    MediaElement.where(:id => @el5.id).update_all(:updated_at => '2011-10-01 19:59:56', :is_public => true, :publication_date => '2012-01-01 10:00:00')
    MediaElement.where(:id => @el6.id).update_all(:updated_at => '2011-10-01 19:59:55')
    MediaElement.where(:id => @el7.id).update_all(:updated_at => '2011-10-01 19:59:54', :is_public => true, :publication_date => '2012-01-01 10:00:00')
    date_now = '2011-01-01 20:00:00'.to_time
    Lesson.order(:id).each do |l|
      Lesson.where(:id => l.id).update_all(:updated_at => date_now)
      date_now -= 1
    end
  end
  
  def setup
    Statistics.user = User.find(1)
  end
  
  test 'my_liked_lessons' do
    load_items
    load_likers
    load_likes
    assert_lesson_likes [[@les1.id, 5], [@les8.id, 4], [@les3.id, 3], [@les6.id, 3]], Statistics.my_liked_lessons(4)
    assert_lesson_likes [[@les1.id, 5], [@les8.id, 4], [@les3.id, 3], [@les6.id, 3], [@les4.id, 2], [@les5.id, 2], [@les7.id, 2], [@les2.id, 1], [@les9.id, 1]], Statistics.my_liked_lessons(9)
  end
  
  test 'all_liked_lessons' do
    load_items
    load_likers
    load_likes
    Lesson.where(:id => [@les1.id, @les2.id, @les3.id, @les4.id]).update_all(:user_id => 2)
    assert_equal 4, Lesson.where('user_id = 2 AND id NOT IN (?)', [1, 2]).count
    assert_equal 5, Lesson.where('user_id = 1 AND id NOT IN (?)', [1, 2]).count
    assert_lesson_likes [[@les8.id, 4], [@les6.id, 3], [@les5.id, 2], [@les7.id, 2]], Statistics.my_liked_lessons(4)
    assert_lesson_likes [[@les1.id, 5], [@les8.id, 4], [@les3.id, 3], [@les6.id, 3]], Statistics.all_liked_lessons(4)
    assert_lesson_likes [[@les1.id, 5], [@les8.id, 4], [@les3.id, 3], [@les6.id, 3], [@les4.id, 2], [@les5.id, 2], [@les7.id, 2], [@les2.id, 1], [@les9.id, 1]], Statistics.all_liked_lessons(9)
  end
  
  test 'all_users_like' do
    load_items
    load_likers
    load_likes
    Lesson.where(:id => [@les1.id, @les6.id]).update_all(:user_id => 2)
    Lesson.where(:id => [@les2.id, @les7.id, @les9.id]).update_all(:user_id => @liker1.id)
    Lesson.where(:id => @les8.id).update_all(:user_id => @liker2.id)
    Like.where(:user_id => [@liker1.id, @liker2.id]).update_all(:user_id => @liker3.id)
    Lesson.where(:id => [1, 2]).delete_all
    assert_equal 3, Lesson.where(:user_id => 1).count
    assert_equal 2, Lesson.where(:user_id => 2).count
    assert_equal 3, Lesson.where(:user_id => @liker1.id).count
    assert_equal 1, Lesson.where(:user_id => @liker2.id).count
    assert Like.where(:user_id => [1, 2, @liker1.id, @liker2.id]).empty?
    User.where(:id => 1).update_all(:created_at => '2012-01-01 10:00:00')
    User.where(:id => 2).update_all(:created_at => '2012-01-01 10:00:01')
    User.where(:id => @liker1.id).update_all(:created_at => '2012-01-01 10:00:02')
    User.where(:id => @liker2.id).update_all(:created_at => '2012-01-01 10:00:03')
    assert_user_likes [[2, 8], [1, 7], [@liker2.id, 4]], Statistics.all_users_like(3)
    assert_user_likes [[2, 8], [1, 7], [@liker2.id, 4], [@liker1.id, 4]], Statistics.all_users_like(5)
    Statistics.user = User.find 1
    assert_equal 7, Statistics.my_likes_count
    Statistics.user = User.find 2
    assert_equal 8, Statistics.my_likes_count
    Statistics.user = User.find @liker1.id
    assert_equal 4, Statistics.my_likes_count
    Statistics.user = User.find @liker2.id
    assert_equal 4, Statistics.my_likes_count
    Lesson.where(:id => @les8.id).update_all(:user_id => @liker1.id)
    assert_equal 0, Statistics.my_likes_count
    Statistics.user = User.find @liker1.id
    assert_equal 8, Statistics.my_likes_count
  end
  
  test 'my_copied_lessons' do
    load_items
    load_likers
    assert_equal 10, Lesson.where(:user_id => 1).count
    assert_equal 1, Lesson.where(:user_id => 2).count
    Lesson.where(:user_id => 1).update_all(:is_public => true)
    Lesson.where(:user_id => 1).each do |l|
      assert User.find(2).bookmark 'Lesson', l.id
    end
    assert !Lesson.find(@les1.id).copy(1).nil?
    assert !Lesson.find(@les1.id).copy(2).nil?
    assert !Lesson.find(@les2.id).copy(2).nil?
    assert !Lesson.find(@les6.id).copy(2).nil?
    assert !Lesson.find(@les7.id).copy(2).nil?
    assert !Lesson.find(@les3.id).copy(1).nil?
    assert_equal 4, Statistics.my_copied_lessons
    assert_equal 6, Lesson.where('parent_id IS NOT NULL').count
  end
  
  test 'my_linked_lessons_count' do
    load_items
    user2 = User.find(2)
    user3 = User.confirmed.new(:name => 'Javier Ernesto', :surname => 'Chevanton3', :school_level_id => 1, :location_id => 1, :password => 'osososos', :password_confirmation => 'osososos', :subject_ids => [1], :purchase_id => 1) do |user|
      user.email = 'em3@em.em'
      user.active = true
    end
    user3.policy_1 = '1'
    user3.policy_2 = '1'
    assert_obj_saved user3
    user4 = User.confirmed.new(:name => 'Javier Ernesto', :surname => 'Chevanton4', :school_level_id => 1, :location_id => 1, :password => 'osososos', :password_confirmation => 'osososos', :subject_ids => [1], :purchase_id => 1) do |user|
      user.email = 'em4@em.em'
      user.active = true
    end
    user4.policy_1 = '1'
    user4.policy_2 = '1'
    assert_obj_saved user4
    assert Bookmark.where('bookmarkable_type = ? AND user_id != ?', 'Lesson', 1).empty?
    assert user2.bookmark 'Lesson', @les1.id
    assert user2.bookmark 'Lesson', @les2.id
    assert user2.bookmark 'Lesson', @les3.id
    assert user2.bookmark 'Lesson', @les4.id
    assert_equal 4, Statistics.my_linked_lessons_count
    assert user3.bookmark 'Lesson', @les3.id
    assert user4.bookmark 'Lesson', @les3.id
    assert_equal 6, Statistics.my_linked_lessons_count
    assert user3.bookmark 'Lesson', @les5.id
    assert user4.bookmark 'Lesson', @les6.id
    assert user4.bookmark 'Lesson', @les1.id
    assert_equal 9, Statistics.my_linked_lessons_count
  end
  
end

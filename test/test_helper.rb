ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  
  fixtures :all
  
  setup :initialize_media_path_for_media_elements, :initialize_attachment_path_for_documents
  
  def assert_status(items, statuses)
    i = 0
    while i < items.length
      assert_buttons items[i].buttons, statuses[i]
      i += 1
    end
  end
  
  def assert_buttons(buttons, buttons_check)
    i = 0
    while i < buttons.length
      assert_equal buttons_check[i], buttons[i]
      i += 1
    end
  end
  
  def assert_invalid_email(object)
    valid_long_email = "#{long_string(249)}@uo.it"
    valid_email = object.email
    valid_email_with_dots = 'fdsfdssf.ds@can.e.it'
    valid_email_with_chars = "cas!\\#$%&'*+-/asfsa=?^_`{|}~afas@azzo.com"
    assert !object.class.pluck(:id).include?(valid_email_with_dots)
    assert !object.class.pluck(:id).include?(valid_long_email)
    assert_invalid object, :email, "#{long_string(250)}@uo.it", valid_long_email, :too_long, {:count => 255}
    assert_invalid object, :email, 'askgfjbdsgkdjsbgdskgjbdsk@.it', valid_email, :not_a_valid_email
    assert_invalid object, :email, '@ldsfihdslgfidshfldsih.it', valid_email, :not_a_valid_email
    assert_invalid object, :email, '@.it', valid_email, :not_a_valid_email
    assert_invalid object, :email, 'ciao ciao@ciao.it', valid_email, :not_a_valid_email
    assert_invalid object, :email, 'ciao;ciao@ciao.it', valid_email, :not_a_valid_email
    assert_invalid object, :email, 'ciao..ciao@ciao.it', valid_email, :not_a_valid_email
    assert_invalid object, :email, 'fdsfds@sfds@cane.it', valid_email_with_dots, :not_a_valid_email
    assert_invalid object, :email, 'fdsfdssfds@cane.i', valid_email, :not_a_valid_email
    assert_invalid object, :email, 'fdsfdssfds.@cane.ii', valid_email_with_chars, :not_a_valid_email
    assert_invalid object, :email, '.fdsfdssfds@cane.iu', valid_email, :not_a_valid_email
    assert_invalid object, :email, '.fdsfdssfds@cane.', valid_email, :not_a_valid_email
    assert_invalid object, :email, '.fdsfdssfds@caneiu', valid_email, :not_a_valid_email
  end
  
  def assert_user_likes(likes, users)
    assert_equal likes.length, users.length
    index = 0
    users.each do |u|
      assert_equal u.id.to_i, likes[index][0]
      assert_equal Like.joins(:lesson).where(:lessons => {:user_id => u.id}).count, likes[index][1]
      assert_equal u.likes_count.to_i, likes[index][1]
      index += 1
    end
  end
  
  def assert_lesson_likes(likes, lessons)
    assert_equal likes.length, lessons.length
    index = 0
    lessons.each do |l|
      assert_equal l.id.to_i, likes[index][0]
      assert_equal Like.where(:lesson_id => l.id).count, likes[index][1]
      assert_equal l.likes_count.to_i, likes[index][1]
      index += 1
    end
  end
  
  def initialize_media_path_for_media_elements
    FileUtils.rm_rf("#{Rails.root.join('public/media_elements/images/test')}/.") if Dir.exists?(Rails.root.join('public/media_elements/images/test'))
    FileUtils.rm_rf("#{Rails.root.join('public/media_elements/audios/test')}/.") if Dir.exists?(Rails.root.join('public/media_elements/audios/test'))
    FileUtils.rm_rf("#{Rails.root.join('public/media_elements/videos/test')}/.") if Dir.exists?(Rails.root.join('public/media_elements/videos/test'))
    [1, 2].each do |x|
      was_public = false
      v = Video.find x
      if v.is_public
        MediaElement.where(:id => x).update_all(:is_public => false)
        was_public = true
      end
      v.media = {:mp4 => Rails.root.join('test/samples/one.mp4').to_s, :webm => Rails.root.join('test/samples/one.webm').to_s, :filename => 'video_test'}
      assert_obj_saved v
      if was_public
        MediaElement.where(:id => x).update_all(:is_public => true)
      end
    end
    [3, 4].each do |x|
      was_public = false
      a = Audio.find x
      if a.is_public
        MediaElement.where(:id => x).update_all(:is_public => false)
        was_public = true
      end
      a.media = {:m4a => Rails.root.join('test/samples/one.m4a').to_s, :ogg => Rails.root.join('test/samples/one.ogg').to_s, :filename => 'audio_test'}
      assert_obj_saved a
      if was_public
        MediaElement.where(:id => x).update_all(:is_public => true)
      end
    end
    [5, 6].each do |x|
      was_public = false
      i = Image.find x
      if i.is_public
        MediaElement.where(:id => x).update_all(:is_public => false)
        was_public = true
      end
      i.media = File.open(Rails.root.join('test/samples/one.jpg'))
      assert_obj_saved i
      if was_public
        MediaElement.where(:id => x).update_all(:is_public => true)
      end
    end
  end
  
  def initialize_attachment_path_for_documents
    FileUtils.rm_rf("#{Rails.root.join('public/documents/test')}/.") if Dir.exists?(Rails.root.join('public/documents/test'))
    [1, 2].each do |x|
      d = Document.find x
      d.attachment = File.open(Rails.root.join('test/samples/one.ppt'))
      assert_obj_saved d
    end
  end
  
  def assert_tags_ordered(tags, words)
    assert_equal tags.length, words.length
    index = 0
    tags.each do |t|
      assert_equal t.word, words[index]
      index += 1
    end
  end
  
  def assert_words_ordered(hash_tags, words)
    tags = []
    hash_tags.each do |v|
      tags << v[:value]
    end
    assert_equal tags.length, words.length
    index = 0
    tags.each do |t|
      assert_equal t, words[index]
      index += 1
    end
  end
  
  def assert_tags(item, tags)
    tags2 = []
    item.taggings.each do |t|
      tags2 << t.tag.word
    end
    assert_equal tags2.sort, tags.sort
  end
  
  def assert_ordered_item_extractor(x1, x2)
    assert_equal x1.length, x2.length, "Error, #{x1.inspect} -- #{x2.inspect}"
    cont = 0
    while cont < x1.length
      assert_equal x1[cont], x2[cont].id, "Error, #{x1.inspect} -- #{x2.inspect}"
      assert !x2[cont].status.nil?
      cont += 1
    end
  end
  
  def assert_extractor_intersection(x1, x2)
    x2.each do |y|
      flag = true
      x1.each do |x|
        flag = false if x.id == y.id
      end
      assert flag
    end
  end
  
  def assert_extractor(my_ids, resp)
    ids = []
    resp.each do |r|
      ids << r.id
    end
    assert_equal ids.sort, my_ids.sort
  end
  
  def assert_item_extractor(my_ids, resp)
    ids = []
    resp.each do |r|
      assert !r.status.nil?
      ids << r.id
    end
    assert_equal ids.sort, my_ids.sort
  end
  
  def assert_invalid(obj, field, before, after, error, error_interpolation=nil)
    obj[field] = before
    assert !obj.save, "#{obj.class} erroneously saved - #{obj.inspect}"
    assert_equal 1, obj.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{obj.errors.inspect}"
    if error_interpolation.nil?
      assert obj.errors.added? field, error
    else
      assert obj.errors.added? field, error, error_interpolation
    end
    obj[field] = after
    assert obj.valid?, "#{obj.class} not valid: #{obj.errors.inspect}"
  end
  
  def assert_obj_saved(obj)
    assert obj.save, "Error saving #{obj.class}: #{obj.errors.inspect}"
  end
  
  def assert_error_size(x, obj)
    assert !obj.valid?, "#{obj.class} valid when not expected! #{obj.inspect}"
    assert_equal x, obj.errors.size, "Expected #{x} errors, got #{obj.errors.size}: #{obj.errors.inspect}"
  end
  
  def assert_default(x, obj, field)
    assert_equal obj[field], x, "Expected default value < #{x.inspect} > for field #{field} of object #{obj.class}, found #{obj[field].inspect}"
  end
  
  def long_string(length)
    x = ''
    i = 0
    while i < length
      x = "#{x}a"
      i += 1
    end
    x
  end
  
end

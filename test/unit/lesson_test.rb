# encoding: UTF-8
require 'test_helper'

class LessonTest < ActiveSupport::TestCase
  
  def setup
    @max_title = I18n.t('language_parameters.lesson.length_title')
    @max_description = I18n.t('language_parameters.lesson.length_description')
    @lesson = Lesson.new :subject_id => 1, :school_level_id => 2, :title => 'Fernandello mio', :description => 'Voglio divenire uno scienziaaato'
    @lesson.copied_not_modified = false
    @lesson.user_id = 1
    @lesson.tags = 'ciao, come, stai, tu?'
  end
  
  test 'valid_fixtures' do
    Lesson.find([1, 2]).each do |l|
      assert l.valid?
    end
  end
  
  test 'token_creation' do
    assert_nil @lesson.token
    assert @lesson.save
    assert_not_nil @lesson.token
    assert @lesson.token.length > 16
    old_token = @lesson.token
    @lesson.title = 'bah'
    assert @lesson.save
    @lesson = Lesson.find @lesson.id
    assert_equal old_token, @lesson.token
  end
  
  test 'uuid_creation' do
    assert_nil @lesson.uuid
    assert @lesson.save
    assert_not_nil @lesson.uuid
    old_uuid = Lesson.find(@lesson.id).uuid
    @lesson.title = 'bah'
    assert @lesson.save
    @lesson = Lesson.find @lesson.id
    assert_equal old_uuid, @lesson.uuid
    # I test the error thrown by the database
    assert_raise(ActiveRecord::StatementInvalid) {Lesson.where(:id => @lesson.id).update_all(:uuid => (Lesson.find(@lesson.id).uuid + 'dagdgdgdsgdsgds'))}
  end
  
  test 'tags' do
    @lesson.save_tags = true
    @lesson.tags = 'gatto, gatto, gatto  ,   , cane, topo'
    assert !@lesson.save, "Lesson erroneously saved - #{@lesson.inspect} -- #{@lesson.tags.inspect}"
    assert_equal 1, @lesson.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@lesson.errors.inspect}"
    assert_equal 1, @lesson.errors.messages[:tags].length
    assert @lesson.errors.added? :tags, :are_not_enough
    @lesson.tags = 'gatto, gatto  ,   , cane, topo'
    assert !@lesson.save, "Lesson erroneously saved - #{@lesson.inspect} -- #{@lesson.tags.inspect}"
    assert_equal 1, @lesson.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@lesson.errors.inspect}"
    assert_equal 1, @lesson.errors.messages[:tags].length
    assert @lesson.errors.added? :tags, :are_not_enough
    assert_equal 7, Tag.count
    @lesson.tags = '  gatto, oRnitOrinco,   , cane, panda  '
    assert_obj_saved @lesson
    assert_equal 7, Tag.count
    @lesson.reload
    assert_tags @lesson, ['gatto', 'cane', 'ornitorinco', 'panda']
    @lesson.tags = '  gattaccio, gattaccio, panda,   , cane, ornitorinco  '
    assert_obj_saved @lesson
    assert_equal 8, Tag.count
    @lesson.reload
    assert_tags @lesson, ['gattaccio', 'cane', 'panda', 'ornitorinco']
    assert Tag.where(:word => 'gattaccio').any?
    @lesson.tags = 'gattaccio, panda, cane, trentatré trentini entrarono a trento tutti e trentatré trotterellando'
    assert !@lesson.save, "Lesson erroneously saved - #{@lesson.inspect} -- #{@lesson.tags.inspect}"
    assert_equal 1, @lesson.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@lesson.errors.inspect}"
    assert_equal 1, @lesson.errors.messages[:tags].length
    assert @lesson.errors.added? :tags, :are_not_enough
    @lesson.reload
    assert_tags @lesson, ['gattaccio', 'cane', 'panda', 'ornitorinco']
    @lesson = Lesson.find @lesson.id
    assert_obj_saved @lesson
    assert_equal 8, Tag.count
    @lesson.reload
    assert_tags @lesson, ['gattaccio', 'cane', 'panda', 'ornitorinco']
  end
  
  test 'too_many_tags' do
    @lesson.save_tags = true
    @lesson.tags = 'de sanctis, benatia, castan, balzaretti, maicon, strootman, de rossi, pjanic, florenzi, totti, gervinho, ljaic, marchetti, cana, konko, ciani, lulic, candreva, ledesma, hernanes, klose, higuain, albiol, britos, reina, mesto, zuniga, insigne, callejon, muntari, balotelli'
    assert !@lesson.save, "Lesson erroneously saved - #{@lesson.inspect} -- #{@lesson.tags.inspect}"
    assert_equal 1, @lesson.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@lesson.errors.inspect}"
    assert_equal 1, @lesson.errors.messages[:tags].length
    assert @lesson.errors.added? :tags, :too_many
    @lesson.tags = 'de sanctis, benatia, castan, balzaretti, maicon, strootman, de rossi, pjanic, florenzi, totti, gervinho, ljaic, marchetti, cana, konko, ciani, lulic, candreva, ledesma, hernanes, klose, higuain, albiol, britos, reina, mesto, zuniga, insigne, callejon, muntari'
    assert_obj_saved @lesson
  end
  
  test 'empty_and_defaults' do
    @lesson = Lesson.new
    assert_equal false, @lesson.is_public
    @lesson.is_public = nil
    @lesson.notified = nil
    assert_error_size 14, @lesson
  end
  
  test 'types' do
    assert_invalid @lesson, :user_id, 'er', 1, :not_a_number
    assert_invalid @lesson, :school_level_id, 0, 2, :greater_than, {:count => 0}
    assert_invalid @lesson, :subject_id, 0.6, 1, :not_an_integer
    assert_invalid @lesson, :parent_id, 'oip', nil, :not_a_number
    assert_invalid @lesson, :parent_id, -6, nil, :greater_than, {:count => 0}
    assert_invalid @lesson, :parent_id, 5.5, nil, :not_an_integer
    assert_invalid @lesson, :is_public, nil, false, :inclusion
    assert_invalid @lesson, :copied_not_modified, nil, false, :inclusion
    assert_invalid @lesson, :title, long_string(@max_title + 1), long_string(@max_title), :too_long, {:count => @max_title}
    assert_invalid @lesson, :description, long_string(@max_description + 1), long_string(@max_description), :too_long, {:count => @max_description}
    assert_invalid @lesson, :notified, nil, false, :inclusion
    assert_obj_saved @lesson
  end
  
  test 'parent_id' do
    assert_invalid @lesson, :parent_id, 1000, 1, :doesnt_exist
    assert_obj_saved @lesson
    assert_invalid @lesson, :parent_id, @lesson.id, 1, :cant_be_the_lesson_itself
    @lesson2 = Lesson.new :subject_id => 1, :school_level_id => 2, :title => 'Fernandello mio', :description => 'Voglio divenire uno scienziaaato'
    @lesson2.copied_not_modified = false
    @lesson2.user_id = 1
    @lesson2.tags = 'ehilà, ohilà, ehi, ciao'
    assert_invalid @lesson2, :parent_id, 1, @lesson.id, :taken
    assert_obj_saved @lesson2
  end
  
  test 'automatic_cover' do
    assert_obj_saved @lesson
    assert_equal 1, Slide.where(:lesson_id => @lesson.id, :kind => 'cover').length
  end
  
  test 'association_methods' do
    assert_nothing_raised {@lesson.user}
    assert_nothing_raised {@lesson.subject}
    assert_nothing_raised {@lesson.school_level}
    assert_nothing_raised {@lesson.bookmarks}
    assert_nothing_raised {@lesson.likes}
    assert_nothing_raised {@lesson.reports}
    assert_nothing_raised {@lesson.taggings}
    assert_nothing_raised {@lesson.slides}
    assert_nothing_raised {@lesson.virtual_classroom_lessons}
    assert_nothing_raised {@lesson.parent}
    assert_nothing_raised {@lesson.copies}
    assert_nothing_raised {@lesson.media_elements_slides}
    assert_nothing_raised {@lesson.media_elements}
  end
  
  test 'associations' do
    assert_invalid @lesson, :user_id, 1000, 1, :doesnt_exist
    assert_invalid @lesson, :school_level_id, 1000, 2, :doesnt_exist
    assert_invalid @lesson, :subject_id, 1000, 1, :doesnt_exist
    assert_obj_saved @lesson
  end
  
  test 'booleans' do
    assert_invalid @lesson, :is_public, true, false, :cant_be_true_for_new_records
    assert_obj_saved @lesson
    @lesson.is_public = true
    assert @lesson.valid?, "Error, #{@lesson.errors.inspect}"
    assert_invalid @lesson, :copied_not_modified, true, false, :cant_be_true_if_public
    assert_obj_saved @lesson
  end
  
  test 'impossible_changes' do
    @lesson.parent_id = 1
    assert_obj_saved @lesson
    old_uuid = @lesson.uuid
    uuid = Lesson.find(@lesson.id).uuid
    new_uuid = uuid[0, uuid.length - 1] + ((uuid[uuid.length - 1] == 'a') ? 'b' : 'a')
    assert new_uuid != uuid
    assert_invalid @lesson, :user_id, 2, 1, :cant_be_changed
    assert_invalid @lesson, :uuid, new_uuid, old_uuid, :cant_be_changed
    old_token = @lesson.token
    last_char = old_token.split(old_token.chop)[1]
    different_token = last_char == 'a' ? "#{old_token.chop}b" : "#{old_token.chop}a"
    assert different_token != old_token
    assert_invalid @lesson, :token, different_token, old_token, :cant_be_changed
    assert_invalid @lesson, :parent_id, 2, 1, :cant_be_changed
    assert_obj_saved @lesson
  end
  
  test 'fathers_and_sons' do
    lesson3 = Lesson.new :subject_id => 1, :school_level_id => 2, :title => 'Fernandello mio', :description => 'Voglio divenire uno scienziaaato'
    lesson3.copied_not_modified = false
    lesson3.user_id = 1
    lesson3.parent_id = 1
    lesson3.tags = 'ehilà, ohilà, ehi, ciao'
    assert_obj_saved lesson3
    lesson4 = Lesson.new :subject_id => 1, :school_level_id => 2, :title => 'Fernandello mio', :description => 'Voglio divenire uno scienziaaato'
    lesson4.copied_not_modified = false
    lesson4.user_id = 2
    lesson4.parent_id = 1
    lesson4.tags = 'ehilà, ohilà, ehi, ciao'
    assert_obj_saved lesson4
    @lesson = Lesson.find 1
    lesson4 = Lesson.find lesson4.id
    lesson3 = Lesson.find lesson3.id
    copies = @lesson.copies.sort
    parent4 = lesson4.parent
    parent3 = lesson3.parent
    assert_equal 2, copies.length
    assert_equal lesson4.id, copies.last.id
    assert_equal lesson3.id, copies.first.id
    assert_equal 1, parent4.id
    assert_equal 1, parent3.id
  end
  
end

# encoding: UTF-8
require 'test_helper'

class MediaElementTest < ActiveSupport::TestCase
  
  def setup
    @max_title = I18n.t('language_parameters.media_element.length_title')
    @max_description = I18n.t('language_parameters.media_element.length_description')
    media = {:mp4 => Rails.root.join('test/samples/one.mp4').to_s, :webm => Rails.root.join('test/samples/one.webm').to_s, :filename => 'video_test'}
    @media_element = Video.new :description => 'Scuola Primaria', :title => 'Scuola', :media => media, :tags => 'ciao, come, stai, tu?'
    @media_element.user_id = 1
  end
  
  test 'valid_fixtures' do
    MediaElement.find([1, 2, 3, 4, 5, 6]).each do |me|
      assert me.valid?
    end
  end
  
  test 'tags' do
    @media_element.save_tags = true
    @media_element.tags = 'gatto, gatto, gatto  ,   , cane, topo'
    assert !@media_element.save, "MediaElement erroneously saved - #{@media_element.inspect} -- #{@media_element.tags.inspect}"
    assert_equal 1, @media_element.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@media_element.errors.inspect}"
    assert_equal 1, @media_element.errors.messages[:tags].length
    assert @media_element.errors.added? :tags, :are_not_enough
    @media_element.tags = 'gatto, gatto  ,   , cane, topo'
    assert !@media_element.save, "MediaElement erroneously saved - #{@media_element.inspect} -- #{@media_element.tags.inspect}"
    assert_equal 1, @media_element.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@media_element.errors.inspect}"
    assert_equal 1, @media_element.errors.messages[:tags].length
    assert @media_element.errors.added? :tags, :are_not_enough
    assert_equal 7, Tag.count
    @media_element.tags = '  gatto, oRnitOrinco,   , cane, panda  '
    assert_obj_saved @media_element
    assert_equal 7, Tag.count
    @media_element.reload
    assert_tags @media_element, ['gatto', 'cane', 'ornitorinco', 'panda']
    @media_element.tags = '  gattaccio, gattaccio, panda,   , cane, ornitorinco  '
    assert_obj_saved @media_element
    assert_equal 8, Tag.count
    @media_element.reload
    assert_tags @media_element, ['gattaccio', 'cane', 'panda', 'ornitorinco']
    assert Tag.where(:word => 'gattaccio').any?
    @media_element.tags = 'gattaccio, panda, cane, trentatré trentini entrarono a trento tutti e trentatré trotterellando'
    assert !@media_element.save, "MediaElement erroneously saved - #{@media_element.inspect} -- #{@media_element.tags.inspect}"
    assert_equal 1, @media_element.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@media_element.errors.inspect}"
    assert_equal 1, @media_element.errors.messages[:tags].length
    assert @media_element.errors.added? :tags, :are_not_enough
    @media_element.reload
    assert_tags @media_element, ['gattaccio', 'cane', 'panda', 'ornitorinco']
    @media_element = MediaElement.find @media_element.id
    @media_element.media = {:mp4 => Rails.root.join("test/samples/one.mp4").to_s, :webm => Rails.root.join("test/samples/one.webm").to_s, :filename => "video_test"}
    assert_obj_saved @media_element
    assert_equal 8, Tag.count
    @media_element.reload
    assert_tags @media_element, ['gattaccio', 'cane', 'panda', 'ornitorinco']
  end
  
  test 'too_many_tags' do
    @media_element.save_tags = true
    @media_element.tags = 'de sanctis, benatia, castan, balzaretti, maicon, strootman, de rossi, pjanic, florenzi, totti, gervinho, ljaic, marchetti, cana, konko, ciani, lulic, candreva, ledesma, hernanes, klose, higuain, albiol, britos, reina, mesto, zuniga, insigne, callejon, muntari, balotelli'
    assert !@media_element.save, "MediaElement erroneously saved - #{@media_element.inspect} -- #{@media_element.tags.inspect}"
    assert_equal 1, @media_element.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@media_element.errors.inspect}"
    assert_equal 1, @media_element.errors.messages[:tags].length
    assert @media_element.errors.added? :tags, :too_many
    @media_element.tags = 'de sanctis, benatia, castan, balzaretti, maicon, strootman, de rossi, pjanic, florenzi, totti, gervinho, ljaic, marchetti, cana, konko, ciani, lulic, candreva, ledesma, hernanes, klose, higuain, albiol, britos, reina, mesto, zuniga, insigne, callejon, muntari'
    assert_obj_saved @media_element
  end
  
  test 'empty_and_defaults' do
    @media_element = MediaElement.new
    assert_equal false, @media_element.is_public
    @media_element.is_public = nil
    assert_error_size 8, @media_element
  end
  
  test 'types' do
    assert_invalid @media_element, :title, long_string(36), long_string(35), :too_long, {:count => @max_title}
    assert_invalid @media_element, :description, long_string(281), long_string(280), :too_long, {:count => @max_description}
    assert_invalid @media_element, :user_id, 'po', 1, :not_a_number
    assert_invalid @media_element, :user_id, -3, 1, :greater_than, {:count => 0}
    assert_invalid @media_element, :user_id, 3.4, 1, :not_an_integer
    assert_invalid @media_element, :is_public, nil, false, :inclusion
    assert_invalid @media_element, :sti_type, 'Film', 'Video', :inclusion
    assert_obj_saved @media_element
  end
  
  test 'association_methods' do
    assert_nothing_raised {@media_element.bookmarks}
    assert_nothing_raised {@media_element.media_elements_slides}
    assert_nothing_raised {@media_element.reports}
    assert_nothing_raised {@media_element.taggings}
    assert_nothing_raised {@media_element.user}
  end
  
  test 'associations' do
    assert_invalid @media_element, :user_id, 900, 1, :doesnt_exist
    assert_obj_saved @media_element
  end
  
  test 'public' do
    # I do manually the assertions of 'assert_invalid' - I check here that it's not possible to save directly is_public = true
    @media_element.publication_date = '2011-01-01 10:00:00'
    @media_element.is_public = true
    assert !@media_element.save, "MediaElement erroneously saved - #{@media_element.inspect}"
    assert_equal 1, @media_element.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@media_element.errors.inspect}"
    assert @media_element.errors.added? :is_public, :must_be_false_if_new_record
    @media_element.is_public = false
    @media_element.publication_date = nil
    assert @media_element.valid?, "MediaElement not valid - #{@media_element.errors.inspect}"
    # here ends assert_invalid
    assert_obj_saved @media_element
    # now it's not a new_record anymore
    assert_invalid @media_element, :sti_type, 'Audio', 'Video', :cant_be_changed
    assert_invalid @media_element, :user_id, 2, 1, :cant_be_changed
    @media_element.title = 'Squola'
    @media_element.description = 'Squola Primaria'
    assert_invalid @media_element, :publication_date, '2011-10-10 10:10:19', nil, :must_be_blank_if_private
    @media_element.is_public = true
    assert_invalid @media_element, :publication_date, 1, '2011-11-11 10:00:00', :is_not_a_date
    assert_obj_saved @media_element
    # again, I simulate assert_invalid - I verify that publication_date and is_public are not editable anymore after having set is_public = true
    @media_element.publication_date = nil
    @media_element.is_public = false
    assert !@media_element.save, "MediaElement erroneously saved - #{@media_element.inspect}"
    assert_equal 2, @media_element.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@media_element.errors.inspect}"
    assert @media_element.errors.added? :is_public, :cant_be_changed_if_public
    assert @media_element.errors.added? :publication_date, :cant_be_changed_if_public
    @media_element.is_public = true
    @media_element.publication_date = '2011-11-11 10:00:00'
    assert @media_element.valid?, "MediaElement not valid - #{@media_element.errors.inspect}"
    # fino a qui
    assert_invalid @media_element, :title, 'Scuola', 'Squola', :cant_be_changed_if_public
    assert_invalid @media_element, :description, 'Scuola Primaria', 'Squola Primaria', :cant_be_changed_if_public
    @media_element.user_id = 2
    assert_equal 1, MediaElement.find(@media_element.id).user_id
    assert_obj_saved @media_element
  end
  
  test 'media_unchangeable' do
    media_one = File.open(Rails.root.join("test/samples/two.jpg"))
    media_two = File.open(Rails.root.join("test/samples/one.jpg"))
    @media_element = MediaElement.find(6)
    @media_element.media = media_two
    assert !@media_element.save, "Image erroneously saved - #{@media_element.inspect}"
    assert_equal 1, @media_element.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@media_element.errors.inspect}"
    assert_equal 1, @media_element.errors.messages[:media].length
    assert @media_element.errors.added? :media, :cant_be_changed_if_public
    @media_element.media = media_one
    assert !@media_element.valid?
    @media_element = MediaElement.find(5)
    @media_element.media = media_two
    assert_obj_saved @media_element
  end
  
  test 'sti_types' do
    assert_equal 2, Audio.count
    assert_equal 2, Video.count
    assert_equal 2, Image.count
    assert_obj_saved @media_element
    assert_equal 2, Audio.count
    assert_equal 3, Video.count
    assert_equal 2, Image.count
  end
  
  test 'stop_destruction' do
    assert_obj_saved @media_element
    @media_element.is_public = true
    @media_element.publication_date = '2011-01-01 10:00:00'
    assert_obj_saved @media_element
    @media_element.destroy
    assert MediaElement.exists?(@media_element.id)
    @media2 = MediaElement.find 1
    @media2.destroy
    assert !MediaElement.exists?(1)
  end
  
  test 'destroy_without_callback_checking_if_public' do
    me = MediaElement.find(1)
    assert_equal 4, me.taggings.count
    assert me.bookmarks.empty?
    assert_equal 1, me.reports.count
    me.is_public = true
    me.publication_date = '2012-01-01 10:00:00'
    assert_obj_saved me
    assert User.find(2).bookmark 'MediaElement', 1
    me = MediaElement.find me.id
    assert_equal 1, me.bookmarks.count
    bookmarks = Bookmark.where(:bookmarkable_type => 'MediaElement', :bookmarkable_id => me.id)
    assert_equal 1, bookmarks.length
    reports = Report.where(:reportable_type => 'MediaElement', :reportable_id => me.id)
    assert_equal 1, reports.length
    taggings = Tagging.where(:taggable_type => 'MediaElement', :taggable_id => me.id)
    assert_equal 4, taggings.length
    me.destroyable_even_if_public = true
    me.destroy
    bookmarks.each do |b|
      assert_nil Bookmark.find_by_id b.id
    end
    reports.each do |r|
      assert_nil Report.find_by_id r.id
    end
    taggings.each do |t|
      assert_nil Tagging.find_by_id t.id
    end
    assert_nil MediaElement.find_by_id me.id
  end
  
  test 'empty_media' do
    [Image, Video, Audio].each do |classe|
      m = classe.new :description => 'Scuola Primaria', :title => 'Scuola'
      m.user_id = 1
      m.tags = 'ciao, come, stai, tu?'
      assert !m.save
      if classe != Image
        m.composing = true
        assert m.save
      end
      m2 = MediaElement.new :description => 'Scuola Primaria', :title => 'Scuola'
      m2.user_id = 1
      m2.tags = 'ciao, come, stai, tu?'
      m2.sti_type = classe.to_s
      assert !m2.save
    end
  end
  
end

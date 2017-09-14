# encoding: UTF-8
require 'test_helper'

class DocumentsSlideTest < ActiveSupport::TestCase
  
  def setup
    @documents_slide = DocumentsSlide.new
    @documents_slide.document_id = 1
    @documents_slide.slide_id = 4
  end
  
  test 'empty_and_defaults' do
    @documents_slide = DocumentsSlide.new
    assert_error_size 6, @documents_slide
  end
  
  test 'types' do
    assert_invalid @documents_slide, :document_id, 'er', 1, :not_a_number
    assert_invalid @documents_slide, :slide_id, 0, 4, :greater_than, {:count => 0}
    assert_invalid @documents_slide, :slide_id, 0.6, 4, :not_an_integer
    assert_obj_saved @documents_slide
  end
  
  test 'association_methods' do
    assert_nothing_raised {@documents_slide.document}
    assert_nothing_raised {@documents_slide.slide}
  end
  
  test 'associations' do
    assert_invalid @documents_slide, :document_id, 1000, 1, :doesnt_exist
    assert_invalid @documents_slide, :slide_id, 1000, 4, :doesnt_exist
    assert_obj_saved @documents_slide
  end
  
  test 'impossible_changes' do
    @doc = Document.new :title => 'oo', :description => 'volare'
    @doc.user_id = 1
    @doc.attachment = File.open(Rails.root.join('test/samples/one.ppt'))
    assert_obj_saved @doc
    @slide = Lesson.last.add_slide 'audio', 2
    assert_not_nil @slide
    assert_obj_saved @documents_slide
    assert_invalid @documents_slide, :document_id, @doc.id, 1, :cant_be_changed
    assert_invalid @documents_slide, :slide_id, @slide.id, 4, :cant_be_changed
    @documents_slide.document_id = 1
    assert_obj_saved @documents_slide
  end
  
  test 'uniqueness' do
    assert_invalid @documents_slide, :document_id, 2, 1, :taken
    assert_obj_saved @documents_slide
  end
  
  test 'allowed_slides' do
    DocumentsSlide.where(:slide_id => 3).delete_all
    Slide.where(:id => 2).update_all(:kind => 'title')
    assert_invalid @documents_slide, :slide_id, 2, 3, :doesnt_allow_documents
    Slide.where(:id => 2).update_all(:kind => 'image2')
    assert_invalid @documents_slide, :slide_id, 2, 3, :doesnt_allow_documents
    Slide.where(:id => 2).update_all(:kind => 'image3')
    assert_invalid @documents_slide, :slide_id, 2, 3, :doesnt_allow_documents
    Slide.where(:id => 2).update_all(:kind => 'image4')
    assert_invalid @documents_slide, :slide_id, 2, 3, :doesnt_allow_documents
    Slide.where(:id => 2).update_all(:kind => 'video2')
    assert_invalid @documents_slide, :slide_id, 2, 3, :doesnt_allow_documents
    Slide.where(:id => 2).update_all(:kind => 'cover')
    assert_invalid @documents_slide, :slide_id, 2, 3, :doesnt_allow_documents
    @documents_slide.slide_id = 2
    Slide.where(:id => 2).update_all(:kind => 'image1')
    assert @documents_slide.valid?
    Slide.where(:id => 2).update_all(:kind => 'video1')
    assert @documents_slide.valid?
    Slide.where(:id => 2).update_all(:kind => 'audio')
    assert @documents_slide.valid?
    Slide.where(:id => 2).update_all(:kind => 'text')
    assert @documents_slide.valid?
  end
  
  test 'max_number_of_documents' do
    assert_obj_saved @documents_slide
    assert_equal 2, @documents_slide.slide.documents_slides.count
    d1 = Document.new :title => 'azzzo', :description => 'asgasg'
    d1.user_id = 1
    d1.attachment = File.open(Rails.root.join('test/samples/one.ppt'))
    assert_obj_saved d1
    d2 = Document.new :title => 'azzzo2', :description => 'asgasg2'
    d2.attachment = File.open(Rails.root.join('test/samples/one.ppt'))
    d2.user_id = 1
    assert_obj_saved d2
    ds1 = DocumentsSlide.new
    ds1.document_id = d1.id
    ds1.slide_id = @documents_slide.slide_id
    assert_obj_saved ds1
    ds2 = DocumentsSlide.new
    ds2.document_id = d2.id
    ds2.slide_id = @documents_slide.slide_id
    assert !ds2.save, "DocumentsSlide erroneously saved - #{ds2.inspect}"
    assert_equal 1, ds2.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{ds2.errors.inspect}"
    assert ds2.errors.added? :base, :too_many_documents
    ds1.destroy
    assert_nil DocumentsSlide.find_by_id ds1.id
    assert_obj_saved ds2
  end
  
end

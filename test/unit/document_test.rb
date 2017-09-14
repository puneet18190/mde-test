# encoding: UTF-8
require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  
  def setup
    @max_title = I18n.t('language_parameters.document.length_title')
    @max_description = I18n.t('language_parameters.document.length_description')
    @document = Document.new :title => 'Fernandello mio', :description => 'Voglio divenire uno scienziaaato', :attachment => File.open(Rails.root.join('test/samples/one.ppt'))
    @document.user_id = 1
  end
  
  test 'empty_and_defaults' do
    @document = Document.new
    assert_error_size 6, @document
  end
  
  test 'types' do
    assert_invalid @document, :user_id, 'er', 1, :not_a_number
    assert_invalid @document, :user_id, 0, 2, :greater_than, {:count => 0}
    assert_invalid @document, :user_id, 0.6, 1, :not_an_integer
    assert_invalid @document, :title, long_string(@max_title + 1), long_string(@max_title), :too_long, {:count => @max_title}
    assert_invalid @document, :description, long_string(@max_description + 1), long_string(@max_description), :too_long, {:count => @max_description}
    assert_obj_saved @document
  end
  
  test 'association_methods' do
    assert_nothing_raised {@document.user}
    assert_nothing_raised {@document.documents_slides}
  end
  
  test 'associations' do
    assert_invalid @document, :user_id, 1000, 1, :doesnt_exist
    assert_obj_saved @document
  end
  
  test 'impossible_changes' do
    assert_obj_saved @document
    assert_invalid @document, :user_id, 2, 1, :cant_be_changed
    assert_obj_saved @document
  end
  
  test 'own_documents' do
    DocumentsSlide.delete_all
    d1 = DocumentsSlide.new
    d1.slide_id = 3
    d1.document_id = 2
    assert_obj_saved d1
    d2 = DocumentsSlide.new
    d2.slide_id = 4
    d2.document_id = 2
    assert_obj_saved d2
    resp = User.find(2).own_documents(1, 20)[:records]
    assert_equal 1, resp.length
    assert_equal 2, resp.first.instances.to_i
    d2.destroy
    assert DocumentsSlide.where(:id => d2.id).empty?
    resp = User.find(2).own_documents(1, 20)[:records]
    assert_equal 1, resp.length
    assert_equal 1, resp.first.instances.to_i
    resp = User.find(1).own_documents(1, 20)[:records]
    assert_equal 1, resp.length
    assert_equal 0, resp.first.instances.to_i
    # I test the mode not in gallery
    assert_raise(NoMethodError) {User.find(1).own_documents(1, 20, SearchOrders::CREATED_AT, nil, true).first.instances}
  end
  
end

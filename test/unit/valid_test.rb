require 'test_helper'
require "#{Rails.root}/lib/autoload/valid.rb"

class ValidTest < ActiveSupport::TestCase
  
  test 'valid' do
    x = User.new
    y = SchoolLevel.find 1
    assert Valid.get_association(x, :id).nil?
    resp = Valid.get_association(y, :id)
    assert_equal SchoolLevel, resp.class
    assert_equal y.id, resp.id, "Expscted #{y.id}, got #{resp.id} -- y was #{y.inspect} -- and resp was #{resp.inspect}"
    x.school_level_id = nil
    assert Valid.get_association(x, :school_level_id).nil?
    x.school_level_id = ''
    assert Valid.get_association(x, :school_level_id).nil?
    x.school_level_id = '   '
    assert Valid.get_association(x, :school_level_id).nil?
    x.school_level_id = 'egev'
    assert Valid.get_association(x, :school_level_id).nil?
    x.school_level_id = 0
    assert Valid.get_association(x, :school_level_id).nil?
    x.school_level_id = -5
    assert Valid.get_association(x, :school_level_id).nil?
    x.school_level_id = "5a1"
    assert Valid.get_association(x, :school_level_id).nil?
    x.school_level_id = 4.4
    assert Valid.get_association(x, :school_level_id).nil?
    x.school_level_id = 1
    resp = Valid.get_association(x, :school_level_id)
    assert_equal SchoolLevel, resp.class
    assert_equal y.id, resp.id, "Expected #{y.id}, got #{resp.id} -- y was #{y.inspect} -- and resp was #{resp.inspect}"
    x.school_level_id = "1"
    resp = Valid.get_association(x, :school_level_id)
    assert_equal SchoolLevel, resp.class
    assert_equal y.id, resp.id, "Expected #{y.id}, got #{resp.id} -- y was #{y.inspect} -- and resp was #{resp.inspect}"
  end
  
  test 'validation_at_risk' do
    x = MediaElementsSlide.find(1)
    assert_equal 'Image', MediaElement.find_by_id(x.media_element_id).sti_type
    assert !x.alignment.nil?
    x.alignment = nil
    assert !x.valid?
  end
  
end

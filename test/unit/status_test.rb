require 'test_helper'

class StatusTest < ActiveSupport::TestCase
  
  test 'lesson' do
    l1 = Lesson.find 1
    assert l1.status.nil?
    assert l1.is_reportable.nil?
    assert l1.buttons.empty?
    l1.set_status 1
    assert_equal Statuses::PRIVATE, l1.status
    assert_equal ['preview', 'edit', 'add_virtual_classroom', 'publish', 'copy', 'destroy'], l1.buttons
    # I try add_to_virtual_classroom
    assert l1.add_to_virtual_classroom(1)
    l1.set_status 1
    assert_equal Statuses::PRIVATE, l1.status
    assert_equal ['preview', 'edit', 'remove_virtual_classroom', 'publish', 'copy', 'destroy'], l1.buttons
    # until here
    l1.set_status 2
    assert l1.status.nil?
    assert l1.is_reportable.nil?
    assert l1.buttons.empty?
    assert l1.publish
    l1.set_status 1
    assert_equal Statuses::SHARED, l1.status
    assert_equal ['preview', 'edit', 'remove_virtual_classroom', 'unpublish', 'copy', 'destroy'], l1.buttons
    assert_equal false, l1.is_reportable
    l1.set_status 2
    assert_equal Statuses::PUBLIC, l1.status
    assert_equal ['preview', 'add', 'like'], l1.buttons
    assert_equal true, l1.is_reportable
    # I try like
    assert User.find(2).like(l1.id)
    l1.set_status 2
    assert_equal Statuses::PUBLIC, l1.status
    assert_equal ['preview', 'add', 'dislike'], l1.buttons
    assert_equal true, l1.is_reportable
    # until here
    assert User.find(2).bookmark('Lesson', 1)
    l1.set_status 2
    assert_equal Statuses::LINKED, l1.status
    assert_equal ['preview', 'copy', 'add_virtual_classroom', 'dislike', 'remove'], l1.buttons
    assert_equal true, l1.is_reportable
    l3 = l1.copy(2)
    assert !l3.nil?
    l3.set_status 2
    assert_equal Statuses::COPIED, l3.status
    assert_equal ['preview', 'edit', 'destroy'], l3.buttons
    assert_equal false, l3.is_reportable
  end
  
  test 'media_element' do
    me1 = MediaElement.find 1
    assert me1.status.nil?
    assert me1.is_reportable.nil?
    assert me1.info_changeable.nil?
    assert me1.buttons.empty?
    me1.set_status 1
    assert_equal Statuses::PRIVATE, me1.status
    assert_equal ['preview', 'edit', 'destroy'], me1.buttons
    assert_equal [false, true], [me1.is_reportable, me1.info_changeable]
    me1.set_status 2
    assert me1.status.nil?
    assert me1.is_reportable.nil?
    assert me1.info_changeable.nil?
    assert me1.buttons.empty?
    me1.is_public = true
    me1.publication_date = '2011-01-01 00:00:01'
    assert_obj_saved me1
    me1.set_status 1
    assert_equal Statuses::PUBLIC, me1.status
    me1.set_status 2
    assert_equal Statuses::PUBLIC, me1.status
    assert_equal ['preview', 'add'], me1.buttons
    assert_equal [true, false], [me1.is_reportable, me1.info_changeable]
    assert User.find(2).bookmark('MediaElement', 1)
    me1.set_status 2
    assert_equal Statuses::LINKED, me1.status
    assert_equal ['preview', 'edit', 'remove'], me1.buttons
    assert_equal [true, false], [me1.is_reportable, me1.info_changeable]
  end
  
end

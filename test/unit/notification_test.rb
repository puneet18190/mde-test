require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  
  def setup
    @notification = Notification.new
    @notification.user_id = 1
    @notification.title = 'Abbiamo una cosa da dirti'
    @notification.message = 'Sei un incompetente, le tue lezioni non piacciono a nessuno!'
    @notification.basement = 'E adesso vattene'
  end
  
  test 'empty_and_defaults' do
    @notification = Notification.new
    assert_equal false, @notification.seen
    @notification.seen = nil
    assert_error_size 6, @notification
  end
  
  test 'types' do
    assert_invalid @notification, :user_id, 'erw', 1, :not_a_number
    assert_invalid @notification, :user_id, 11.1, 1, :not_an_integer
    assert_invalid @notification, :user_id, 0, 1, :greater_than, {:count => 0}
    assert_invalid @notification, :title, long_string(256), long_string(255), :too_long, {:count => 255}
    assert_invalid @notification, :seen, nil, false, :inclusion
    assert_obj_saved @notification
  end
  
  test 'associations' do
    assert_invalid @notification, :user_id, 1000, 1, :doesnt_exist
    assert_obj_saved @notification
  end
  
  test 'association_methods' do
    assert_nothing_raised {@notification.user}
  end
  
  test 'initial_seen' do
    assert_invalid @notification, :seen, true, false, :must_be_false_if_new_record
    assert_obj_saved @notification
  end
  
  test 'impossible_changes' do
    assert_obj_saved @notification
    @notification.seen = true
    assert_obj_saved @notification
    assert_invalid @notification, :user_id, 2, 1, :cant_be_changed
    assert_invalid @notification, :title, 'Ti dobbiamo dire una cosa', 'Abbiamo una cosa da dirti', :cant_be_changed
    assert_invalid @notification, :message, 'Sei un perdente, le tue lezioni non piacciono a nessuno!', 'Sei un incompetente, le tue lezioni non piacciono a nessuno!', :cant_be_changed
    assert_invalid @notification, :basement, 'E adesso vattene via', 'E adesso vattene', :cant_be_changed
    assert_invalid @notification, :seen, false, true, :cant_be_switched_from_true_to_false
    assert_obj_saved @notification
  end
  
end

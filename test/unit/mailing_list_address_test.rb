require 'test_helper'

class MailingListAddressTest < ActiveSupport::TestCase
  
  def setup
    @mailing_list_address = MailingListAddress.new
    @mailing_list_address.group_id = 1
    @mailing_list_address.heading = 'cane'
    @mailing_list_address.email = 'cane@cane.cn'
  end
  
  test 'empty_and_defaults' do
    @mailing_list_address = MailingListAddress.new
    assert_error_size 5, @mailing_list_address
  end
  
  test 'types' do
    assert_invalid_email @mailing_list_address
    assert_invalid @mailing_list_address, :group_id, '3r4', 2, :not_a_number
    assert_invalid @mailing_list_address, :group_id, -4, 2, :greater_than, {:count => 0}
    assert_invalid @mailing_list_address, :group_id, 2.111, 1, :not_an_integer
    assert_invalid @mailing_list_address, :heading, long_string(256), long_string(255), :too_long, {:count => 255}
    assert_obj_saved @mailing_list_address
  end
  
  test 'association_methods' do
    assert_nothing_raised {@mailing_list_address.group}
  end
  
  test 'associations' do
    assert_invalid @mailing_list_address, :group_id, 1000, 2, :doesnt_exist
    assert_obj_saved @mailing_list_address
  end
  
  test 'impossible_changes' do
    assert_obj_saved @mailing_list_address
    assert_invalid @mailing_list_address, :group_id, 2, 1, :cant_be_changed
    assert_obj_saved @mailing_list_address
  end
  
end

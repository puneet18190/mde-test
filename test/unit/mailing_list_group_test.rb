require 'test_helper'

class MailingListGroupTest < ActiveSupport::TestCase
  
  def setup
    @mailing_list_group = MailingListGroup.new
    @mailing_list_group.user_id = 1
    @mailing_list_group.name = 'Cani ahrahrahra'
  end
  
  test 'empty_and_defaults' do
    @mailing_list_group = MailingListGroup.new
    assert_error_size 4, @mailing_list_group
  end
  
  test 'types' do
    assert_invalid @mailing_list_group, :user_id, '3r4', 2, :not_a_number
    assert_invalid @mailing_list_group, :user_id, -4, 2, :greater_than, {:count => 0}
    assert_invalid @mailing_list_group, :user_id, 2.111, 1, :not_an_integer
    assert_invalid @mailing_list_group, :name, long_string(256), long_string(255), :too_long, {:count => 255}
    assert_obj_saved @mailing_list_group
  end
  
  test 'association_methods' do
    assert_nothing_raised {@mailing_list_group.user}
    assert_nothing_raised {@mailing_list_group.addresses}
  end
  
  test 'uniqueness' do
    assert_invalid @mailing_list_group, :name, 'Amici ahrahrahra', 'Amici ahrarahra', :taken
    assert_obj_saved @mailing_list_group
    mlg2 = MailingListGroup.new
    mlg2.user_id = 2
    used_name = 'Amici ahrahrahra'
    assert MailingListGroup.where(:name => used_name).any?
    assert MailingListGroup.where(:name => used_name, :user_id => 2).empty?
    mlg2.name = used_name
    assert_obj_saved mlg2
  end
  
  test 'associations' do
    assert_invalid @mailing_list_group, :user_id, 1000, 2, :doesnt_exist
    assert_obj_saved @mailing_list_group
  end
  
  test 'impossible_changes' do
    assert_obj_saved @mailing_list_group
    assert_invalid @mailing_list_group, :user_id, 2, 1, :cant_be_changed
    assert_obj_saved @mailing_list_group
  end
  
end

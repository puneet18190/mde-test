require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
    @user = User.confirmed.new(:name => 'Javier Ernesto', :surname => 'Chevanton', :school_level_id => 1, :location_id => 1, :password => 'osososos', :password_confirmation => 'osososos', :subject_ids => [1], :purchase_id => 1) do |user|
      user.email = 'em1@em.em'
      user.active = true
    end
    @user.policy_1 = '1'
    @user.policy_2 = '1'
  end
  
  test 'empty_and_defaults' do
    @user = User.new
    assert_error_size 12, @user
  end
  
  test 'types' do
    assert_invalid_email @user
    assert_invalid @user, :name, long_string(256), long_string(255), :too_long, {:count => 255}
    assert_invalid @user, :surname, long_string(256), long_string(255), :too_long, {:count => 255}
    assert_invalid @user, :school_level_id, 'er', 1, :not_a_number
    assert_invalid @user, :school_level_id, -2, 1, :greater_than, {:count => 0}
    assert_invalid @user, :school_level_id, 2.8, 1, :not_an_integer
    assert_invalid @user, :purchase_id, 'er', 1, :not_a_number
    assert_invalid @user, :location_id, -2, 1, :greater_than, {:count => 0}
    assert_invalid @user, :location_id, 2.8, 1, :not_an_integer
    assert_invalid @user, :active, nil, false, :inclusion
    assert_invalid @user, :confirmed, nil, true, :inclusion
    assert_obj_saved @user
    @user.location_id = nil
    assert_obj_saved @user
    @user.purchase_id = nil
    assert_obj_saved @user
  end
  
  test 'uniqueness' do
    assert_invalid @user, :email, 'pluto@pippo.it', 'reer@dsigs.nz', :taken
    assert_obj_saved @user
  end
  
  test 'associations' do
    l = Location.new
    l.sti_type = 'County'
    l.ancestry = nil
    l.name = 'Dogville'
    assert_obj_saved l
    new_location_id = l.id
    assert_invalid @user, :location_id, 1900, 1, :doesnt_exist
    assert_invalid @user, :location_id, new_location_id, 1, :doesnt_exist
    assert_invalid @user, :school_level_id, 1900, 1, :doesnt_exist
    assert_invalid @user, :purchase_id, 100, 1, :doesnt_exist
    assert_obj_saved @user
  end
  
  test 'association_methods' do
    assert_nothing_raised {@user.bookmarks}
    assert_nothing_raised {@user.notifications}
    assert_nothing_raised {@user.likes}
    assert_nothing_raised {@user.lessons}
    assert_nothing_raised {@user.media_elements}
    assert_nothing_raised {@user.reports}
    assert_nothing_raised {@user.users_subjects}
    assert_nothing_raised {@user.subjects}
    assert_nothing_raised {@user.virtual_classroom_lessons}
    assert_nothing_raised {@user.school_level}
    assert_nothing_raised {@user.location}
    assert_nothing_raised {@user.documents}
    assert_nothing_raised {@user.purchase}
  end
  
  test 'purchases' do
    User.where(:id => [1, 2]).update_all(:purchase_id => 1)
    Purchase.where(:id => 1).update_all(:accounts_number => 2)
    assert_equal 2, User.count
    assert_invalid @user, :purchase_id, 1, nil, :too_many_users_for_purchase
    assert_obj_saved @user
    assert_equal 3, User.count
    assert_invalid @user, :purchase_id, 1, nil, :too_many_users_for_purchase
    User.where(:id => 1).update_all(:purchase_id => nil)
    @user.purchase_id = 1
    assert_obj_saved @user
  end
  
  test 'email_and_password_confirmation' do
    user = User.confirmed.new(:name => 'Javier Ernesto', :surname => 'Chevanton', :school_level_id => 1, :location_id => 1, :password => 'osososos', :subject_ids => [1], :purchase_id => 1) do |user|
      user.email = 'ema1@em.em'
      user.active = true
      user.policy_1 = '1'
      user.policy_2 = '1'
    end
    assert user.valid?
    # email confirmation
    user.email_confirmation = 'ema1@em2.em'
    assert !user.save, "User erroneously saved - #{user.inspect}"
    assert_equal 1, user.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{user.errors.inspect}"
    assert user.errors.added? :email_confirmation, :confirmation, :attribute => 'Email'
    user.email_confirmation = 'ema1@em.em'
    assert user.valid?, "User not valid: #{user.errors.inspect}"
    # password confirmation
    user.password_confirmation = 'ososos0s'
    assert !user.save, "User erroneously saved - #{user.inspect}"
    assert_equal 1, user.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{user.errors.inspect}"
    assert user.errors.added? :password_confirmation, :confirmation, :attribute => 'Password'
    user.password_confirmation = 'osososos'
    assert user.valid?, "User not valid: #{user.errors.inspect}"
    assert_obj_saved user
  end
  
end

# ### Description
#
# Contains the actions to handle mailing lists and addresses. All these actions can be called from UsersController#mailing_lists
#
# ### Models used
#
# * User
# * MailingListGroup
# * MailingListAddress
#
class MailingListsController < ApplicationController
  
  before_filter :initialize_mailing_list_group_with_owner, :only => [:create_address, :update_group, :delete_group]
  before_filter :initialize_mailing_list_address_with_owner, :only => :delete_address
  
  # ### Description
  #
  # Creates a new group
  #
  # ### Mode
  #
  # Ajax
  #
  def create_group
    @mailing_list_group = MailingListGroup.new
    @mailing_list_group.user = current_user
    @mailing_list_group.name = current_user.new_mailing_list_name
    @ok = @mailing_list_group.save
    render 'update_list'
  end
  
  # ### Description
  #
  # Creates a new address inside a given group
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * MailingListController#initialize_mailing_list_group_with_owner
  #
  def create_address
    if @ok
      @mailing_list_address = MailingListAddress.new
      @mailing_list_address.group_id = @mailing_list_group.id
      @mailing_list_address.heading = params[:heading]
      @mailing_list_address.email = params[:email]
      @ok = @mailing_list_address.save
    end
    render 'update_addresses'
  end
  
  # ### Description
  #
  # Updates an existing group (it's possible to change the name)
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * MailingListController#initialize_mailing_list_group_with_owner
  #
  def update_group
    if @ok
      @mailing_list_group.name = params[:name]
      @ok = @mailing_list_group.save
      @mailing_list_group = MailingListGroup.find @mailing_list_group_id if !@ok
    end
  end
  
  # ### Description
  #
  # Removes a group
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * MailingListController#initialize_mailing_list_group_with_owner
  #
  def delete_group
    @mailing_list_group.destroy if @ok
    render 'update_list'
  end
  
  # ### Description
  #
  # Removes an address inside a group
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * MailingListController#initialize_mailing_list_address_with_owner
  #
  def delete_address
    @mailing_list_address.destroy if @ok
    render 'update_addresses'
  end
  
  private
  
  # Initializes mailing list group and checks that current_user is the owner
  def initialize_mailing_list_group_with_owner
    initialize_mailing_list_group
    update_ok(!@mailing_list_group.nil? && current_user.id == @mailing_list_group.user_id)
  end
  
  # Initializes mailing list group
  def initialize_mailing_list_group
    @mailing_list_group_id = correct_integer?(params[:group_id]) ? params[:group_id].to_i : 0
    @mailing_list_group = MailingListGroup.find_by_id @mailing_list_group_id
    update_ok(!@mailing_list_group.nil?)
  end
  
  # Initializes mailing list address and checks that current_user is the owner of the corresponding group
  def initialize_mailing_list_address_with_owner
    initialize_mailing_list_address
    initialize_mailing_list_group
    update_ok(!@mailing_list_address.nil? && !@mailing_list_group.nil? && @mailing_list_address.group_id == @mailing_list_group.id && current_user.id == @mailing_list_group.user_id)
  end
  
  # Initializes mailing list address
  def initialize_mailing_list_address
    @mailing_list_address_id = correct_integer?(params[:address_id]) ? params[:address_id].to_i : 0
    @mailing_list_address = MailingListAddress.find_by_id @mailing_list_address_id
    update_ok(!@mailing_list_address.nil?)
  end
  
end

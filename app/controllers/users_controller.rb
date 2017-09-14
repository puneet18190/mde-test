# ### Description
#
# Controller for actions related to user's profile and statistics
#
# ### Models used
#
# * User
# * UserMailer
# * Location
# * Subject
# * SchoolLevel
#
# ### Subcontrollers
#
# * Users::SessionsController
#
class UsersController < ApplicationController
  
  skip_before_filter :authenticate, :only => [
    :create,
    :confirm,
    :request_reset_password,
    :reset_password,
    :send_reset_password,
    :request_upgrade_trial,
    :send_upgrade_trial,
    :find_locations,
    :toggle_locations
  ]
  before_filter :initialize_layout, :only => [
    :edit,
    :update,
    :subjects,
    :update_subjects,
    :statistics,
    :mailing_lists,
    :trial,
    :logged_upgrade_trial
  ]
  layout 'fullpage_notification', :only => [
    :request_reset_password,
    :reset_password,
    :send_reset_password,
    :request_upgrade_trial,
    :send_upgrade_trial,
    :confirm,
    :create
  ]
  
  # ### Description
  #
  # Creates a profile which is not confirmed yet
  #
  # ### Mode
  #
  # Html
  #
  # ### Skipped filters
  #
  # * ApplicationController#authenticate
  #
  def create
    @saas = SETTINGS['saas_registration_mode']
    subject_ids = []
    if params[:subjects].present?
      params[:subjects].each do |k, v|
        subject_ids << k.split('_').last.to_i
      end
    end
    user_saved = false
    ActiveRecord::Base.transaction do
      @user = User.active.not_confirmed.new
      @user.email = params[:email]
      @user.email_confirmation = params[:email_confirmation]
      @user.name = params[:name]
      @user.surname = params[:surname]
      @user.password = params[:password]
      @user.password_confirmation = params[:password_confirmation]
      @user.school_level_id = params[:school_level_id]
      @user.subject_ids = subject_ids
      if params[:policies].present?
        params[:policies].keys.each do |policy|
          @user.send(:"#{policy}=", '1')
        end
      end
      if @saas && params[:trial].blank?
        purchase = Purchase.find_by_token params[:purchase_id]
        @user.purchase_id = purchase ? purchase.id : 0
      end
      if params.has_key?(:location) && params[:location][LAST_LOCATION].to_i != 0
        @user.location_id = params[:location][LAST_LOCATION]
      end
      user_saved = @user.save
      raise ActiveRecord::Rollback if !user_saved
    end
    if user_saved
      UserMailer.account_confirmation(@user).deliver
      if @saas
        desy = SETTINGS['application_name']
        if @user.trial?
          Notification.send_to(
            @user.id,
            I18n.t('notifications.account.trial.title', :user_name => @user.name),
            I18n.t('notifications.account.trial.message', :desy => desy, :validity => SETTINGS['saas_trial_duration']),
            I18n.t('notifications.account.trial.basement', :desy => desy, :link => upgrade_trial_link)
          )
        else
          Notification.send_to(
            @user.id,
            I18n.t('notifications.account.welcome.title', :user_name => @user.name),
            I18n.t('notifications.account.welcome.message', :desy => desy, :expiration_date => TimeConvert.to_string(purchase.expiration_date)),
            ''
          )
        end
        purchase = @user.purchase
        UserMailer.purchase_full(purchase).deliver if purchase && User.where(:purchase_id => purchase.id).count >= purchase.accounts_number
      end
      render 'users/fullpage_notifications/confirmation/email_sent'
    else
      initialize_registration_form(subject_ids)
      @errors = convert_user_error_messages @user.errors
      render 'prelogin/registration', :layout => 'prelogin'
    end
  end
  
  # ### Description
  #
  # Confirms a profile using the link with token received by e-mail by the user
  #
  # ### Mode
  #
  # Html
  #
  # ### Skipped filters
  #
  # * ApplicationController#authenticate
  #
  def confirm
    if User.confirm!(params[:token])
      render 'users/fullpage_notifications/confirmation/received'
    else
      render 'users/fullpage_notifications/expired_link'
    end
  end
  
  # ### Description
  #
  # Opens the page where the user writes an email to reset the password
  #
  # ### Mode
  #
  # Html
  #
  # ### Skipped filters
  #
  # * ApplicationController#authenticate
  #
  def request_reset_password
  end
  
  # ### Description
  #
  # Sends to the user an email containing the reset password token
  #
  # ### Mode
  #
  # Html
  #
  # ### Skipped filters
  #
  # * ApplicationController#authenticate
  #
  def send_reset_password
    email = params[:email]
    if email.blank?
      redirect_to user_request_reset_password_path, { flash: { alert: t('flash.email_is_blank') } }
      return
    end
    if user = User.active.confirmed.where(email: email).first
      user.password_token!
      UserMailer.new_password(user).deliver
    end
    render 'users/fullpage_notifications/reset_password/email_sent'
  end
  
  # ### Description
  #
  # Checks the token and resets the password; sends to the user an email containing the new password
  #
  # ### Mode
  #
  # Html
  #
  # ### Skipped filters
  #
  # * ApplicationController#authenticate
  #
  def reset_password
    new_password, user = *User.reset_password!(params[:token])
    if new_password
      UserMailer.new_password_confirmed(user, new_password).deliver
      render 'users/fullpage_notifications/reset_password/received'
    else
      render 'users/fullpage_notifications/expired_link'
    end
  end
  
  # ### Description
  #
  # Opens the page where the user writes an email and a purchase code to upgrade his trial account
  #
  # ### Mode
  #
  # Html
  #
  # ### Skipped filters
  #
  # * ApplicationController#authenticate
  #
  def request_upgrade_trial
    if !SETTINGS['saas_registration_mode']
      redirect_to root_path
      return
    end
  end
  
  # ### Description
  #
  # Sends to the user an email containing the upgrade trial token
  #
  # ### Mode
  #
  # Html
  #
  # ### Skipped filters
  #
  # * ApplicationController#authenticate
  #
  def send_upgrade_trial
    if !SETTINGS['saas_registration_mode']
      redirect_to root_path
      return
    end
    if params[:email].blank? || params[:password].blank? || params[:purchase_id].blank?
      redirect_to user_request_upgrade_trial_path, { flash: { alert: t('flash.upgrade_trial.missing_fields') } }
      return
    end
    user = User.active.confirmed.where(:email => params[:email]).first
    if !user || !user.trial? || !user.valid_password?(params[:password])
      redirect_to user_request_upgrade_trial_path, { flash: { alert: t('flash.upgrade_trial.wrong_login_or_not_trial') } }
      return
    end
    purchase = Purchase.find_by_token(params[:purchase_id])
    if !purchase || purchase.users.count >= purchase.accounts_number
      redirect_to user_request_upgrade_trial_path, { flash: { alert: t('flash.upgrade_trial.purchase_token_not_valid') } }
      return
    end
    user.purchase_id = purchase.id
    user.location_id = purchase.location_id if purchase.location && purchase.location.sti_type.downcase == LAST_LOCATION
    if !user.save
      redirect_to user_request_upgrade_trial_path, { flash: { alert: t('flash.upgrade_trial.generic_error') } }
      return
    end
    Notification.send_to(
      user.id,
      I18n.t('notifications.account.upgraded.title'),
      I18n.t('notifications.account.upgraded.message', :expiration_date => TimeConvert.to_string(purchase.expiration_date)),
      ''
    )
  end
  
  # ### Description
  #
  # Form to edit the general information about your profile
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_layout
  #
  def edit
    @user = current_user
    initialize_general_profile(@user.location)
    @errors = []
  end
  
  # ### Description
  #
  # Updates your profile.
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_layout
  #
  def update
    @user = current_user
    if params.has_key?(:location) && params[:location][LAST_LOCATION].to_i != 0
      @user.location_id = params[:location][LAST_LOCATION]
    end
    @user.name = params[:name]
    @user.surname = params[:surname]
    @user.school_level_id = params[:school_level_id]
    if params[:password] && params[:password].present?
      @user.password = params[:password]
      @user.password_confirmation = params[:password_confirmation]
    end
    if @user.save
      redirect_to my_profile_path, { flash: { notice: t('users.info.ok_popup') } }
    else
      @errors = convert_user_error_messages @user.errors
      if @errors[:subjects].any? || @errors[:policies].any? || @errors[:purchase].any? || @user.errors.messages.has_key?(:email)
        redirect_to my_profile_path, { flash: { alert: t('users.info.wrong_popup') } }
      else
        initialize_general_profile(@user.location)
        @errors = @errors[:general]
        render :edit
      end
    end
  end
  
  # ### Description
  #
  # Form to edit your list of subjects
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_layout
  #
  def subjects
    @user = current_user
    initialize_subjects_profile(true)
    @errors = []
  end
  
  # ### Description
  #
  # Updates your subjects.
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_layout
  #
  def update_subjects
    @user = current_user
    subject_ids = []
    if params[:subjects].present?
      params[:subjects].each do |k, v|
        subject_ids << k.split('_').last.to_i
      end
    end
    if @user.update(subject_ids: subject_ids)
      redirect_to my_subjects_path, { flash: { notice: t('users.subjects.ok_popup') } }
    else
      @errors = convert_user_error_messages @user.errors
      if @errors[:general].any? || @errors[:policies].any? || @errors[:purchase].any?
        redirect_to my_subjects_path, { flash: { alert: t('users.subjects.wrong_popup') } }
      else
        initialize_subjects_profile(true)
        @errors = @errors[:subjects]
        render :subjects
      end
    end
  end
  
  # ### Description
  #
  # Section of your profile about trial version handling
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_layout
  #
  def trial
    if !current_user.trial?
      redirect_to my_profile_path
      return
    end
  end
  
  # ### Description
  #
  # Sends to the user an email containing the upgrade trial token
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_layout
  #
  def logged_upgrade_trial
    if !current_user.trial?
      redirect_to my_profile_path
      return
    end
    user = current_user
    purchase = Purchase.find_by_token(params[:purchase_id])
    if !purchase || purchase.users.count >= purchase.accounts_number
      @error = t('users.trial.errors.code_not_valid')
      render 'trial'
      return
    end
    user.purchase_id = purchase.id
    user.location_id = purchase.location_id if purchase.location && purchase.location.sti_type.downcase == LAST_LOCATION
    if !user.save
      @error = t('users.trial.errors.problem_saving')
      render 'trial'
      return
    end
    Notification.send_to(
      user.id,
      I18n.t('notifications.account.upgraded.title'),
      I18n.t('notifications.account.upgraded.message', :expiration_date => TimeConvert.to_string(purchase.expiration_date)),
      ''
    )
    redirect_to dashboard_path, { flash: { notice: t('users.trial.successful_upgrade') } }
  end
  
  # ### Description
  #
  # Necessary to fill the locations list
  #
  # ### Mode
  #
  # Html
  #
  # ### Skipped filters
  #
  # * ApplicationController#authenticate
  #
  def find_locations
    if params[:id] == '0'
      @parent = Location.new
      @first_depth = 1
    else
      @parent = Location.find_by_id params[:id]
      @first_depth = params[:empty_children].present? ? (@parent.depth + 2) : (@parent.depth + 1)
    end
    @locations = @parent.select_with_selected
    @location_types = LOCATION_TYPES
  end
  
  # ### Description
  #
  # Toggles locations between active and disabled, in the registration form: used in case the user doesn't find his location in the database.
  #
  # ### Mode
  #
  # Html
  #
  # ### Skipped filters
  #
  # * ApplicationController#authenticate
  #
  def toggle_locations
    @location_types = LOCATION_TYPES
    @on = params[:on] == 'true'
    if @on
      location = Location.find_by_id(correct_integer?(params[:location_id]) ? params[:location_id].to_i : 0)
      if location.nil?
        @locations = Location.roots.order(:name)
        @depth = 0
      else
        @locations = location.children.order(:name)
        @depth = location.depth + 1
      end
    else
      @depth = correct_integer?(params[:depth]) ? (params[:depth].to_i - 1) : 0
    end
  end
  
  # ### Description
  #
  # Manage your mailing lists and addresses (see MailingListsController)
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_layout
  #
  def mailing_lists
  end
  
  # ### Description
  #
  # Static page with general and personal statistics
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_layout
  #
  def statistics
    Statistics.user = current_user
    @my_created_lessons      = Statistics.my_created_lessons
    @my_created_elements     = Statistics.my_created_elements
    @my_copied_lessons       = Statistics.my_copied_lessons
    @my_liked_lessons        = Statistics.my_liked_lessons(3)
    @my_linked_lessons_count = Statistics.my_linked_lessons_count
    @all_liked_lessons       = Statistics.all_liked_lessons(3)
    @my_likes_count          = Statistics.my_likes_count
    @all_shared_elements     = Statistics.all_shared_elements
    @all_shared_lessons      = Statistics.all_shared_lessons
    @all_users               = Statistics.all_users
    @all_users_like          = Statistics.all_users_like(3)
    @subjects_chart          = {
      :data   => Statistics.subjects_chart,
      :texts  => Statistics.subjects,
      :colors => Subject.chart_colors
    }
  end
  
  private
  
  # Function to be overwritten if the upgrade trial path changes
  def upgrade_trial_link
    my_trial_path
  end
  
end

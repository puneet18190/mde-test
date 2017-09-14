# ### Description
#
# Contains the actions called while the user is not logged in
#
# ### Models used
#
# * User
# * SchoolLevel
# * Location
# * Subject
#
class PreloginController < ApplicationController
  
  skip_before_filter :authenticate
  before_filter :redirect_to_dashboard_if_logged_in
  layout 'prelogin'
    
  # ### Description
  #
  # Home page of the application
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * PreloginController#redirect_to_dashboard_if_logged_in
  #
  # ### Skipped filters
  #
  # * ApplicationController#authenticate
  #
  def home
  end
  
  # ### Description
  #
  # Matches the purchase code in the sign_up form
  #
  # ### Mode
  #
  # Js
  #
  # ### Specific filters
  #
  # * PreloginController#redirect_to_dashboard_if_logged_in
  #
  # ### Skipped filters
  #
  # * ApplicationController#authenticate
  #
  def purchase_code
    if !SETTINGS['saas_registration_mode']
      render :nothing => true
      return
    end
    @load_locations = params[:dont_load_locations].blank?
    @purchase = Purchase.find_by_token(params[:token])
    @purchase = nil if @purchase && @purchase.users.count >= @purchase.accounts_number
    if @purchase && @purchase.location
      @location_types = LOCATION_TYPES
      @forced_location = @purchase.location
      @locations = @forced_location.select_with_selected
    end
  end
  
  # ### Description
  #
  # Form to sign in
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * PreloginController#redirect_to_dashboard_if_logged_in
  #
  # ### Skipped filters
  #
  # * ApplicationController#authenticate
  #
  def registration
    @saas = SETTINGS['saas_registration_mode']
    @user = User.new
    initialize_registration_form
    @errors = {
      :general  => [],
      :subjects => [],
      :policies => [],
      :purchase => []
    }
  end
  
  # ### Description
  #
  # Section of the main page
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * PreloginController#redirect_to_dashboard_if_logged_in
  #
  # ### Skipped filters
  #
  # * ApplicationController#authenticate
  #
  def what_is
  end
  
  private
  
  # If the user is logged in, redirects to DashboardController#index
  def redirect_to_dashboard_if_logged_in
    if logged_in?
      redirect_to dashboard_path
      return
    end
  end
  
end

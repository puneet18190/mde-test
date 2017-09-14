# ### Description
#
# Controller of purchases in the administration section. See AdminController.
#
# ### Models used
#
# * AdminSearchForm
# * Purchase
# * Location
#
class Admin::PurchasesController < AdminController
  
  before_filter :check_saas
  layout 'admin'
  
  # ### Description
  #
  # Main page of the section 'purchases' in admin. If params[:search] is present, it is used AdminSearchForm to perform the requested search.
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  # * Admin::PurchaseController#check_saas
  #
  def index
    if !@ok
      redirect_to '/admin'
      return
    end
    purchases = AdminSearchForm.search_purchases((params[:search] ? params[:search] : {:ordering => 0, :desc => 'true'}))
    @purchases = purchases.page(params[:page])
  end
  
  # ### Description
  #
  # Form to edit a purchase
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  # * Admin::PurchaseController#check_saas
  #
  def edit
    @purchase = Purchase.find_by_id params[:id]
  end
  
  # ### Description
  #
  # Action to update a purchase
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  # * Admin::PurchaseController#check_saas
  #
  def update
    @purchase = Purchase.find_by_id params[:id]
    if @purchase.update purchase_attributes
      @ok = true
    else
      @ok = false
      @errors = @purchase.errors.messages.keys
      @errors << :ssn_code if @errors.include?(:base)
    end
  end
  
  # ### Description
  #
  # Form to create a new purchase
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  # * Admin::PurchaseController#check_saas
  #
  def new
    @renewed = Purchase.find_by_id params[:renew]
    @purchase = Purchase.new
    @locations = Location.roots.order(:name)
    if @renewed
      @purchase.name = @renewed.name
      @purchase.responsible = @renewed.responsible
      @purchase.phone_number = @renewed.phone_number
      @purchase.fax = @renewed.fax
      @purchase.email = @renewed.email
      @purchase.ssn_code = @renewed.ssn_code
      @purchase.vat_code = @renewed.vat_code
      @purchase.address = @renewed.address
      @purchase.postal_code = @renewed.postal_code
      @purchase.city = @renewed.city
      @purchase.country = @renewed.country
      @purchase.includes_invoice = @renewed.includes_invoice
      @purchase.release_date = Time.zone.now
      @purchase.start_date = @renewed.expiration_date
    end
  end
  
  # ### Description
  #
  # Action to create a new purchase
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  # * Admin::PurchaseController#check_saas
  #
  def create
    @purchase = Purchase.new purchase_attributes
    if @purchase.save
      @ok = true
      renewed = Purchase.find_by_id params[:renewed_id]
      if renewed
        renewed.users.each do |u|
          u.purchase_id = @purchase.id
          u.save
          Notification.send_to(
            u.id,
            I18n.t('notifications.account.renewed.title'),
            I18n.t('notifications.account.renewed.message', :expiration_date => TimeConvert.to_string(@purchase.expiration_date)),
            ''
          )
        end
        renewed.expiration_date = Time.zone.now
        renewed.save
      end
    else
      @ok = false
      @errors = @purchase.errors.messages.keys
      @errors << :ssn_code if @errors.include?(:base)
    end
  end
  
  # ### Description
  #
  # Action to send to a list of emails the instructions to use the purchase code
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  # * Admin::PurchaseController#check_saas
  #
  def send_link
    @purchase = Purchase.find_by_id params[:id]
    if !@purchase
      redirect_to '/admin/purchases'
      return
    end
    @message = params[:message].blank? ? I18n.t('admin.purchases.links.empty_message') : params[:message]
    UserMailer.purchase_resume(params[:emails].split(','), @purchase, @message).deliver
    redirect_to '/admin/purchases'
  end
  
  # ### Description
  #
  # Form to send to a list of emails the instructions to use the purchase code
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  # * Admin::PurchaseController#check_saas
  #
  def link_form
    @purchase = Purchase.find_by_id params[:id]
    if !@purchase
      redirect_to '/admin/purchases'
      return
    end
  end
  
  # ### Description
  #
  # It fills the locations in the restriction form; specific for purchases
  #
  # ### Mode
  #
  # Js
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  # * Admin::PurchaseController#check_saas
  #
  def find_locations
    parent = Location.find_by_id params[:id]
    @locations = parent.nil? ? [] : parent.children.order(:name)
  end
  
  # ### Description
  #
  # It fills the locations in the restriction form, receiving as input an id or a code
  #
  # ### Mode
  #
  # Js
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  # * Admin::PurchaseController#check_saas
  #
  def fill_locations
    location_id = Location.where(:id => params[:id], :sti_type => params[:sti_type].camelize).first
    location_code = params[:code].present? ? Location.where(:code => params[:code], :sti_type => params[:sti_type].camelize).first : nil
    @location = location_id.nil? ? location_code : location_id
    if @location
      @ok = true
      @locations = @location.select_with_selected(false)
    else
      @ok = false
    end
  end
  
  private

  def purchase_attributes
    case action_name
    when 'create' then params.require(:purchase).permit *Purchase::ATTR_ACCESSIBLE
    when 'update' then params.require(:purchase).permit *Purchase::ATTR_ACCESSIBLE+[:includes_invoice]
    end
  end
  
  # Filter that checks if this section is enabled
  def check_saas
    @ok = (SETTINGS['saas_registration_mode'] && current_user.super_admin?)
  end
  
end

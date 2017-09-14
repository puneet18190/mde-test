# ### Description
#
# ActiveRecord class that corresponds to the table +purchases+.
#
# ### Fields
#
# * *name*: name of the buyer
# * *responsible*: name and surname of the person who is responsible for the transaction
# * *phone_number*: phone number of the responsible
# * *fax*: fax of the responsible
# * *email*: official email of the buyer
# * *ssn_code*: personal code
# * *vat_code*: code of the company
# * *address*: address of the buyer
# * *postal_code*: postal code of the buyer
# * *city*: city of the buyer
# * *country*: country of the buyer
# * *accounts_number*: how many accounts are associated to this purchase
# * *includes_invoice*: if true, the purchae must be associated to an invoice (not implemented in the application)
# * *release_date*: date of purchase
# * *start_date*: date of beginning of the validity of the purchase
# * *expiration_date*: expiration date of the purchase
# * *location_id*: location which must be forced to the users who benefit this purchase
# * *token*: token used to associate a user subscription to this purchase
#
# ### Associations
#
# * *users*: users associated to this purchase (see User) (*has_many*)
# * *location*: location to which all the user must belong (this is not inserted into a validation, not to overload the model, but just in the methods for the frontend) (*belongs_to*, it can be nil)
#
# ### Validations
#
# * *presence* of +name+, +responsible+, +email+, +accounts_number+, +release_date+, +start_date+, +expiration_date+
# * *numericality* greater than 0 for +accounts_number+
# * *numericality* greater than 0 and allow_nil and eventually presence of associated object for +location_id+
# * *length* of +name+, +responsible+, +phone_number+, +fax+, +email+, +ssn_code+, +vat_code+, +address+, +postal_code+, +city+, +country+ (maximum 255)
# * *inclusion* of +includes_invoice+ in [true, false]
# * *correctness* of +email+ as an e-mail address
# * *format* of dates +release_date+, +start_date+, +expiration_date+
# * *presence* of at least one between +vat_code+ and +ssn_code+
# * *modifications* *not* *available* for +token+
# * *decrease* *not* *available* for +accounts_number+
# * *uniqueness* ok +token+
#
# ### Callbacks
#
# 1. *before_create* creates a random encoded string and writes it in +token+
#
# ### Database callbacks
#
# None
#
class Purchase < ActiveRecord::Base
  
  # List of attributes which are accessible for mass assignment
  ATTR_ACCESSIBLE = [ :accounts_number, :address, :city, :country, :email, 
                      :expiration_date, :fax, :includes_invoice, :location_id, 
                      :name, :phone_number, :postal_code, :release_date, 
                      :responsible, :ssn_code, :start_date, :vat_code ]
  
  has_many :users
  belongs_to :location
  
  validates_presence_of :name, :responsible, :email, :accounts_number, :release_date, :start_date, :expiration_date
  validates_numericality_of :accounts_number, :greater_than => 0, :only_integer => true
  validates_numericality_of :location_id, :greater_than => 0, :only_integer => true, :allow_nil => true
  validates_uniqueness_of :token
  validates_length_of :name, :responsible, :phone_number, :fax, :email, :ssn_code, :vat_code, :address, :postal_code, :city, :country, :maximum => 255
  validates_inclusion_of :includes_invoice, :in => [true, false]
  
  validate :validate_email, :validate_dates, :validate_associations, :validate_codes, :validate_impossible_changes
  
  before_validation :init_validation
  before_create :create_token
  
  # ### Description
  #
  # Used in the front end, it returns a resume of the address depending on the field filled up
  #
  # ### Returns
  #
  # A string
  #
  def address_to_s
    resp = ([self.address, self.postal_code, self.city, self.country].reject {|i| i.blank?}).join(', ')
  end
  
  # ### Description
  #
  # Method used in the front end that returns the resume of the location
  #
  # ### Returns
  #
  # A string
  #
  def location_to_s
    return I18n.t('admin.purchases.links.empty_location') if self.location_id.nil?
    resp = ''
    my_location = self.location
    locations = []
    first = true
    current_location = self.location
    return '-' if current_location.nil?
    while !current_location.nil?
      locations << current_location
      current_location = current_location.parent
    end
    locations.reverse.each do |l|
      if first
        resp = "#{l.name}"
        first = false
      else
        resp = "#{resp} - #{l.name}"
      end
    end
    resp
  end
  
  # ### Description
  #
  # Checks if the actual time is greater than expiration_date
  #
  # ### Returns
  #
  # A boolean
  #
  def expired?
    self.expiration_date < Time.zone.now
  end
  
  private
  
  # Initializes the objects needed for the validation
  def init_validation
    @purchase = Valid.get_association self, :id
    @location = Valid.get_association self, :location_id
  end
  
  # Validates that at least one between vat_code and ssn_code is present
  def validate_codes
    errors.add :base, :missing_both_codes if self.vat_code.blank? && self.ssn_code.blank?
  end
  
  # Validates the presence of associated elements
  def validate_associations
    errors.add :location_id, :doesnt_exist if @location.nil? && self.location_id.present?
  end
  
  # Validates the correct format of the email (see Valid.email?)
  def validate_email
    return if self.email.blank?
    errors.add(:email, :not_a_valid_email) if !Valid.email?(self.email)
  end
  
  # Validates the correct format of the dates
  def validate_dates
    errors.add(:release_date, :is_not_a_date) if !self.release_date.kind_of?(Time)
    errors.add(:start_date, :is_not_a_date) if !self.start_date.kind_of?(Time)
    errors.add(:expiration_date, :is_not_a_date) if !self.expiration_date.kind_of?(Time)
  end
  
  # Validates that if the purchase is not new record the field +accounts_number+ cannot be changed
  def validate_impossible_changes
    if @purchase
      errors.add(:accounts_number, :cant_be_decreased) if @purchase.accounts_number > self.accounts_number
      errors.add(:token, :cant_be_changed) if @purchase.token != self.token
    end
  end
  
  # Callback that creates a random secure token and sets is as the +token+ of the purchase
  def create_token
    my_token = generate_token
    while Purchase.where(:token => my_token).any?
      my_token = generate_token
    end
    self.token = my_token
    true
  end
  
  # Token generator
  def generate_token
    resp = SecureRandom.random_number(10000000000000000).to_s
    while resp.length < 16
      resp = "0#{resp}"
    end
    resp
  end
  
end

require 'securerandom'

# Provides the User confirmation logic
module User::Confirmation

  module ClassMethods

    # Generate a confirmation token by looping and ensuring does not already exist
    def generate_confirmation_token
      loop do
        token = SecureRandom.urlsafe_base64(16)
        break token unless where(confirmation_token: token).first
      end
    end

    # Searches for a user with a confirmation_token equals to the token arg; if found confirms it
    #
    # ### Returns
    #
    # The matched user if found; +nil+ otherwise
    def confirm!(token)
      user = active.not_confirmed.where(confirmation_token: token).first
      return nil unless user
      user.confirmed = true
      user.save
    end
  end
  
  module InstanceMethods
    # If the user is confirmed deletes the confirmation_token attribute; sets it otherwise
    def confirmation_token!
      if confirmed?
        self.confirmation_token = nil
      else
        self.confirmation_token = self.class.generate_confirmation_token unless confirmation_token
      end
      true
    end
  end
  
  # When included, sets User::Confirmation::InstanceMethods#confirmation_token! as +before_save+
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods

    receiver.instance_eval do
      before_save :confirmation_token!
    end
  end
end

require 'securerandom'

# Provides the User logics for resetting the password of a user
module User::ResetPassword
  
  # Module containing the class methods
  module ClassMethods
    
    # Generates the token to reset the password
    def generate_password_token
      loop do
        token = SecureRandom.urlsafe_base64(16)
        break token unless where(:password_token => token).first
      end
    end
    
    # Resets the password, together with the password token
    def reset_password!(token)
      user = User.where(:password_token => token).first
      return [nil, nil] unless user
      if user.password_token
        user.password_token = nil
        new_password = SecureRandom.urlsafe_base64(10)
        user.password = new_password
        user.password_confirmation = new_password
        user.save!
        return [new_password, user]
      end
    end
    
  end
  
  # Module containing the instance methods
  module InstanceMethods
    
    # Sets the password token using the automatic generator
    def password_token!
      self.password_token = self.class.generate_password_token
      self.save!
    end
    
  end
  
  # Initializes the methods
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
  
  
end

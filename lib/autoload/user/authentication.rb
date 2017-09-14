require 'bcrypt'

# Provides the User authentication logic
module User::Authentication
  
  # Path to the file which contains the pepper key
  PEPPER_PATH = Rails.root.join('config/pepper')
  
  # Pepper key
  PEPPER      = (PEPPER_PATH.exist? and PEPPER_PATH.read.chomp) or (
    warn "The file #{PEPPER_PATH} does not exists or is empty."
    warn "Generating a new pepper and writing to #{PEPPER_PATH}; this will invalidate the previous user passwords."
    require 'securerandom'
    SecureRandom.hex(64).tap{ |token| PEPPER_PATH.open('w'){ |io| io.write token } }
  )
  
  # BCrypt processing cost
  COST = 10
  
  module ClassMethods
    
    # Strings comparison time-attacks safe
    #
    # ### Returns
    #
    # +true+ if the strings match, +false+ otherwise
    def secure_compare(a, b)
      # constant-time comparison algorithm to prevent timing attacks
      return false if a.blank? || b.blank? || a.bytesize != b.bytesize
      l = a.unpack "C#{a.bytesize}"
      res = 0
      b.each_byte { |byte| res |= byte ^ l.shift }
      res == 0
    end
  end
  
  module InstanceMethods
    
    # Encrypts the password using BCrypt algorythm
    def encrypt_password
      if password and !password.empty?
        self.encrypted_password = BCrypt::Password.create("#{password}#{PEPPER}", cost: COST).to_s
      end
      true
    end
    
    # Checks whether a string matches the password hash or not
    #
    # ### Returns
    #
    # +true+ if the string matches, +false+ otherwise
    def valid_password?(password)
      bcrypt = BCrypt::Password.new(encrypted_password)
      password = BCrypt::Engine.hash_secret("#{password}#{PEPPER}", bcrypt.salt)
      self.class.secure_compare(password, encrypted_password)
    end
    
    # Clears +password+ and +password_confirmation+ attributes
    def clear_password_and_password_confirmation
      self.password = nil
      self.password_confirmation = nil
    end
  end
  
  # When included, sets User::Authentication::InstanceMethods#encrypt_password as +before_save+ and User::Authentication::InstanceMethods#clear_password_and_password_confirmation as +after_save+
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
    receiver.instance_eval do
      before_save :encrypt_password
      after_save  :clear_password_and_password_confirmation
    end
  end
  
end

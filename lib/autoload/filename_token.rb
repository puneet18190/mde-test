# Provides methods for a model which can be used to set a token good to be used in a filename which will be served by a web server
module FilenameToken

  module InstanceMethods
    # Sets/retrieves the <tt>@filename_token</tt> instance variable
    def filename_token
      @filename_token ||= SecureRandom.urlsafe_base64(16)
    end

    private
    # Resets the <tt>@filename_token</tt> instance variable
    def reset_filename_token
      @filename_token = nil
    end
  end
  
  # When included, sets FilenameToken::InstanceMethods#reset_filename_token as +before_save+
  def self.included(receiver)
    receiver.send :include, InstanceMethods
    receiver.instance_eval do
      before_save :reset_filename_token
    end
  end

end
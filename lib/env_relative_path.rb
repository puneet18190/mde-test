require 'pathname'

# Provides a way to get the right path for the Rails environment according to this rule:
#
# * if Rails environment is production, the path remains unaltered
# * otherwise the path becomes relative to the enviroment string
#
# The method +env_relative_pathname+ returns a Pathname instance instead of a String.
#
# ### Examples
#
#  # Rails.env == "production"
#  env_relative_path('asd') #=> 'asd'
#
#  # Rails.env == "development"
#  env_relative_path('asd') #=> 'development/asd'
module EnvRelativePath
  module ClassMethods
    # See EnvRelativePath
    def env_relative_path(*paths)
      File.join(Rails.env.production? ? paths : paths + [Rails.env])
    end

    # See EnvRelativePath
    def env_relative_pathname(*paths)
      Pathname.new File.join(Rails.env.production? ? paths : paths + [Rails.env])
    end
  end
  
  def self.included(receiver)
    receiver.extend ClassMethods
  end
end

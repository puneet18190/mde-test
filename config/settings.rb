require 'yaml'

module SettingsLoader

  # Load settings or exit; defines SETTINGS constant
  def self.load_settings(config)
    path = Pathname config.paths[config.settings_path].first

    unless path.exist?
      abort "The settings file #{path} was not found; you can create it copying #{path}.example to it and customizing it."
    end

    YAML.load path.read
  end

end
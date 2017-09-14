require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Desy
  class Application < Rails::Application

    # Maintenance response
    config.middleware.use 'Rack::Maintenance', file: Rails.root.join('public', '503.html').to_s, env: 'MAINTENANCE'

    # Per-application settings path
    config.settings_path = 'config/settings.yml'

    # Per-application settings file paths
    config.paths.add config.settings_path

    # Load per-application settings
    require_relative 'settings'
    config.settings = ::SettingsLoader.load_settings config
    ::SETTINGS      = config.settings

    # Seeds files depending by environment paths
    config.db_seeds_enviroment_path = "db/seeds/environments/#{Rails.env}"
    config.paths.add config.db_seeds_enviroment_path

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += ["#{Rails.root}/lib/autoload"]

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = ::SETTINGS['languages'].first

    # Allow available locales only
    I18n.enforce_available_locales = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    config.active_record.schema_format = :sql

    # Options used by url_for when used in email contexts
    config.action_mailer.default_url_options = SETTINGS['application']['default_url_options']

    # More than one language
    config.more_than_one_language = ::SETTINGS['languages'].size > 1

    # Prefix for temporary files and folders
    config.tempfiles_prefix = ->() { "#{::SETTINGS['tempfiles_prefix']}.#{Thread.current.object_id}" }

    # Stylesheets configs
    config.assets.stylesheets = ActiveSupport::OrderedOptions.new
    config.assets.stylesheets.paths = ActiveSupport::OrderedOptions.new
    # Assets urls declarations
    config.assets.stylesheets.paths.urls = Rails.root.join 'app', 'assets', 'stylesheets', 'urls.scss.erb'
  end

end

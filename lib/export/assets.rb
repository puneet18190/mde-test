require 'fileutils'
require 'pathname'
require 'uri'

require 'sprockets'
require 'sprockets/rails/helper'

require 'export'

module Export
  # This class implements assets logic for exporting logics. It uses Sprockets
  # adapting some configuration from sprockets-rails.
  class Assets

    def self.folder
      self::FOLDER
    end

    def self.remove_folder!
      FileUtils.rm_rf folder
    end

    def self.compiled?
      new.compiled?
    end

    def self.compile
      new.compile
    end

    def folder
      self.class.folder
    end

    def compiled?
      folder.exist? && folder.entries.present?
    end

    def compile
      folder.rmtree if folder.exist?
      folder.mkpath

      assets.each_logical_path(paths) do |logical_path|
        if asset = assets.find_asset(logical_path)
          write_asset(asset)
        end
      end
    end

    private

    def write_asset(asset)
      asset.logical_path.tap do |path|
        filename = File.join folder, path
        FileUtils.mkdir_p File.dirname filename
        asset.write_to(filename)
      end
    end

    # Adapted from sprockets-rails-2.0.1/lib/sprockets/railtie.rb, the relevant parts
    def assets
      @assets ||= Sprockets::Environment.new(::Rails.root.to_s) do |env|
        ::Rails.application.assets.paths.each { |v| env.append_path v }

        env.context_class.class_eval do
          include ::Sprockets::Rails::Helper
          
          def pathname_nestings
            nesting = 0
            @pathname.ascend do |v|
              break if v.to_s.in? ::Rails.application.config.assets.paths
              nesting += 1
            end
            nesting
          end

          def asset_path_upfolders
            @asset_path_upfolders ||= {}
            @asset_path_upfolders[@pathname] ||= (['..'] * pathname_nestings).join('/')
          end
        end

        env.context_class.instance_eval do
          def sass_config
            ::Rails.application.assets.context_class.sass_config
          end
        end

        env.js_compressor  = ::Rails.application.config.assets.js_compressor
        env.css_compressor = ::Rails.application.config.assets.css_compressor
      end
    end

    def paths
      raise 'Must be implemented by a subclass'
    end

  end
end

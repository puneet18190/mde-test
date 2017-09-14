require 'fileutils'
require 'pathname'
require 'uri'

require 'sprockets'

require 'export'
require 'export/lesson'
require 'export/lesson/ebook'
require 'export/assets'

module Export
  module Lesson
    class Ebook
      class Assets < Assets

        FOLDER = INPUT_ASSETS_FOLDER
        PATHS  = ASSETS_PATHS

        def paths
          @paths ||= ASSETS_PATHS
        end

        private

        def env
          @sub_env ||= begin
            assets = super

            assets.context_class.class_eval do
              def asset_path(source, options = {})
                URI.escape "../assets/#{source}"
              end
            end

            assets
          end
        end
        
      end
    end
  end
end

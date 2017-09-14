require 'fileutils'
require 'pathname'
require 'uri'

require 'sprockets'

require 'export'
require 'export/lesson'
require 'export/lesson/archive'
require 'export/assets'

module Export
  module Lesson
    class Archive
      class Assets < Assets

        FOLDER = INPUT_ASSETS_FOLDER

        def assets
          @sub_assets ||= begin
            assets = super

            assets.context_class.class_eval do
              def asset_path(source, options = {})
                URI.escape "#{asset_path_upfolders}/assets/#{source}"
              end
            end

            assets
          end
        end

        def paths
          @paths ||= %W(
            documents/doc.svg
            documents/exc.svg
            documents/pdf.svg
            documents/ppt.svg
            documents/unknown.svg
            documents/zip.svg
            bg_title_editor.gif
            documents_fondo.png
            favicon32x32.png
            icone-player.svg
            lesson-editor-logo-footer.png
            nav_left.png
            nav_right.png
            pallino.svg
            set-icone-editor.svg
            tiny_items.gif
            lesson_archive/application.css
            lesson_archive/application.js
            browser_not_supported/application.css
            browser_not_supported/application.js
          )
        end
        
      end
    end
  end
end

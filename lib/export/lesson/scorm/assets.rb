require 'fileutils'
require 'pathname'
require 'uri'
require 'sprockets'
require 'export'
require 'export/lesson'
require 'export/lesson/scorm'
require 'export/assets'

module Export
  
  module Lesson
    
    class Scorm
      
      class Assets < Assets
        
        FOLDER = INPUT_ASSETS_FOLDER
        
        def env
          @sub_env ||= begin
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
            pallino.svg
            set-icone-editor.svg
            tiny_items.gif
            lesson_scorm/application.css
            lesson_scorm/application.js
          )
        end
        
      end
      
    end
    
  end
  
end

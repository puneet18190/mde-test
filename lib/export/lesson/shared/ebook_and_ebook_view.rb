require 'export'
require 'export/lesson'
require 'export/lesson/shared'

module Export
  module Lesson
    module Shared
      module EbookAndEbookView
        require 'export/lesson/ebook/view'

        DOCUMENT_FALLBACKS_RELATIVE_FROM_CONTENTS_FOLDER = File.join DocumentUploader::STORE_DIR, 'fallbacks'

        def slide_item_id(slide)
          "slide_#{slide.position-1}"
        end

        def slide_filename(slide)
          "#{slide_item_id(slide)}.xhtml"
        end

        def document_item_id(document)
          "document_#{document.id}"
        end

        def document_item_fallback_id(document)
          "#{document_item_id(document)}_fallback"
        end

        def document_fallback_filename(document)
          "#{document_item_fallback_id(document)}.xhtml"
        end

        def document_fallbacks_relative_from_content_path(document)
          File.join DOCUMENT_FALLBACKS_RELATIVE_FROM_CONTENTS_FOLDER, document_fallback_filename(document)
        end

        def math_image_path_relative_from_contents_folder(math_image_filename)
          File.join self.class::FILE_MATH_IMAGES_FOLDER_NAME, math_image_filename
        end

      end 
    end
  end
end
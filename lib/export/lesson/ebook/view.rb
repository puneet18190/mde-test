require 'export'
require 'export/lesson'
require 'export/lesson/ebook'

require 'action_view/lookup_context'

module Export
  module Lesson
    class Ebook
      class View < View
        require 'export/lesson/ebook/view/helper'

        include Helper
        #self.helpers = [Helper]

        FOLDER           = Lesson::FOLDER.join 'ebooks', 'views'
        LOOKUP_CONTEXT   = begin
          lookup_context = ActionView::LookupContext.new FOLDER
          lookup_context.view_paths.push *Rails.application.config.paths['app/views'].to_a
          lookup_context
        end
        RENDERER         = Renderer.new LOOKUP_CONTEXT
        CONTEXT          = RENDERER
        INSTANCE         = new RENDERER

        def self.instance
          INSTANCE
        end
      end
    end
  end
end
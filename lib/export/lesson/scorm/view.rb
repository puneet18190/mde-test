require 'export'
require 'export/lesson'
require 'export/lesson/scorm'
require 'action_view/lookup_context'

module Export
  module Lesson
    class Scorm
      class View < View

        require 'export/lesson/scorm/view/helper'

        include Helper
        #self.prepare nil, Helper

        FOLDER           = Lesson::FOLDER.join 'scorms', 'views'
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

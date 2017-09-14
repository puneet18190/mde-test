require 'export'
require 'export/lesson'
require 'export/lesson/scorm'
require 'export/lesson/scorm/view'
require 'export/lesson/shared'

module Export
  module Lesson
    class Scorm
      class View
        module Helper
          include Rails.application.routes.url_helpers
          
          SCORM_LOCALE         = I18n.default_locale
          SCORM_SCHOOL_LEVELS  = {}
          
          def scorm_locale
            SCORM_LOCALE
          end
          
          def default_url_options
            SETTINGS['application']['default_url_options']
          end
          
          def scorm_school_level(school_level)
            resp = SCORM_SCHOOL_LEVELS[school_level]
            resp.nil? ? 'school' : resp.html_safe
          end
          
          def scorm_slide_title(slide)
            return 'Cover' if slide.cover?
            resp = "Slide #{slide.position - 1}"
            resp = "#{resp} - #{slide.title}" if slide.title.present?
            resp.html_safe
          end
          
          def ims_duration(media_element, extension)
            duration = media_element.send(:"#{extension}_duration").round(1)
            float_seconds = ((duration - duration.to_i) * 10).to_i
            duration = duration.to_i
            seconds = duration % 60
            duration = duration / 60
            minutes = duration % 60
            hours = duration / 60
            if hours > 0
              return "PT#{hours}H#{minutes}M#{seconds}.#{float_seconds}S"
            elsif minutes > 0
              return "PT#{minutes}M#{seconds}.#{float_seconds}S"
            else
              return "PT#{seconds}.#{float_seconds}S"
            end
          end
          
        end
      end
    end
  end
end

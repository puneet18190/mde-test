require 'export'

# ### Description
#
# Controller for exporting lessons
#
# ### Models used
#
# * Lesson
# * Slide
# * DocumentsSlide
# * MediaElementsSlide
#
class LessonExportController < ApplicationController
  
  skip_before_filter :authenticate
  before_filter :initialize_and_authenticate_for_lesson_export, :redirect_or_setup
  layout 'lesson_archive', only: :archive
  
  # ### Description
  #
  # Exports the lesson in format HTML
  #
  # ### Mode
  #
  # Html
  #
  # ### Skipped filters
  #
  # * ApplicationController#authenticate
  #
  # ### Specific filters
  #
  # * LessonExportController#initialize_and_authenticate_for_lesson_export
  # * LessonExportController#redirect_or_setup
  #
  def archive
    @slides = @lesson.slides.preload( :media_elements_slides                    ,
                                      { media_elements_slides: :media_element } ,
                                      :documents_slides                         ,
                                      { documents_slides: :document }
                                    ).order(:position)
    redirect_to Export::Lesson::Archive.new(@lesson, render_to_string).url
  end
  
  # ### Description
  #
  # Exports the lesson in format EPUB
  #
  # ### Mode
  #
  # Html
  #
  # ### Skipped filters
  #
  # * ApplicationController#authenticate
  #
  # ### Specific filters
  #
  # * LessonExportController#initialize_and_authenticate_for_lesson_export
  # * LessonExportController#redirect_or_setup
  #
  def ebook
    redirect_to Export::Lesson::Ebook.new(@lesson).url
  end
  
  # ### Description
  #
  # Exports the lesson in format SCORM
  #
  # ### Mode
  #
  # Html
  #
  # ### Skipped filters
  #
  # * ApplicationController#authenticate
  #
  # ### Specific filters
  #
  # * LessonExportController#initialize_and_authenticate_for_lesson_export
  # * LessonExportController#redirect_or_setup
  #
  def scorm
    rendered_slides = {}
    @lesson.slides.each do |slide|
      @slide_id = slide.id
      rendered_slides[slide.id] = render_to_string({
        :template => "lesson_viewer/slides/_#{slide.kind}",
        :layout   => 'lesson_scorm',
        :locals   => {
          :slide    => slide,
          :url_type => UrlTypes::SCORM_HTML,
          :loaded   => true
        }
      })
    end
    redirect_to Export::Lesson::Scorm.new(@lesson, rendered_slides).url
  end
  
  private
  
  # Authenticates the user and checks the token if he is not authenticated. Similar to the filter in LessonViewerController
  def initialize_and_authenticate_for_lesson_export
    @lesson_id = correct_integer?(params[:lesson_id]) ? params[:lesson_id].to_i : 0
    @lesson = Lesson.find_by_id @lesson_id
    @ok = !@lesson.nil?
    return if !@ok
    if logged_in?
      if current_user.trial?
        @ok = @lesson.is_public
        return
      else
        @ok = (@lesson.is_public || @lesson.user_id == current_user.id)
        return
      end
    end
    @ok = (@lesson.is_public || @lesson.token == params[:token])
  end
  
  # Checks if the lesson is available, i.e. it doesn't contain audios or videos in conversion. Same filter in LessonEditorController
  def redirect_or_setup
    if !@ok
      redirect_to dashboard_path
      return
    end
    if !@lesson.available?
      render 'not_available', :layout => 'lesson_editor'
      return
    end
  end
  
end

# ### Description
#
# Contains the actions used in the lesson viewer (view sinle lessons, or view your whole playlist)
#
# ### Models used
#
# * Lesson
# * VirtualClassroomLesson
#
class LessonViewerController < ApplicationController
  
  skip_before_filter :authenticate, :only => :index
  before_filter :skip_authenticate_user_if_token, :only => :index
  
  # ### Description
  #
  # Index of a single lesson viewer; it's not necessary to authenticate, if in the url is present the correct token of the lesson
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * LessonViewerController#skip_authenticate_user_if_token
  #
  # ### Skipped filters
  #
  # * ApplicationController#authenticate
  #
  def index
    if !@ok
      redirect_to '/dashboard'
    else
      @with_exit = logged_in?
      @back = params[:back]
      @slides = @lesson.slides.preload(:media_elements_slides, {:media_elements_slides => :media_element}, :documents_slides, {:documents_slides => :document}).order(:position)
    end
  end
  
  # ### Description
  #
  # Index of the playlist viewer
  #
  # ### Mode
  #
  # Html
  #
  def playlist
    @with_exit = false
    @back = '/virtual_classroom'
    @slides = current_user.playlist_for_viewer
    @vc_lessons = current_user.playlist(true)
    if @vc_lessons.length == 0
      redirect_to '/dashboard'
      return
    else
      covers = Slide.where(:lesson_id => @vc_lessons.pluck(:lesson_id), :kind => 'cover').preload(:media_elements_slides, {:media_elements_slides => :media_element})
      @covers = {}
      covers.each do |cov|
        @covers[cov.lesson_id] = cov
      end
    end
  end
  
  private
  
  # If the user has the token, it's not necessary to check that the lesson is public
  def skip_authenticate_user_if_token
    initialize_lesson
    update_ok(@lesson.is_public || (logged_in? && session[:user_id].to_i == @lesson.user_id)) if @ok && @lesson.token != params[:token]
  end
  
end

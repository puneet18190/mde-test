# ### Description
#
# Controller for all the actions related to lessons and their buttons. The only two action buttons excluded here are VirtualClassroomController#add_lesson and VirtualClassroomController#remove_lesson. All over this controller we use the constant keywords defined in ButtonDestinations, namely:
# 1. *found_lesson* (or simply *found*) for a lesson seen in a results list of the search engine
# 2. *compact_lesson* (or simply *compact*) for a lesson seen in the compact mode
# 3. *expanded_lesson* (or simply *expanded*) for a lesson seen in expanded mode (this happens only in the dashboard, see DashboardController)
#
# ### Models used
#
# * Lesson
# * User
#
class LessonsController < ApplicationController
  
  # Number of compact lessons for each page
  FOR_PAGE = 8
  
  before_filter :check_available_for_user, :only => [:copy, :publish]
  before_filter :initialize_lesson, :only => [:add, :copy, :like, :remove, :dislike]
  before_filter :initialize_lesson_with_owner, :only => [:destroy, :publish, :unpublish, :dont_notify_modification, :notify_modification]
  before_filter :initialize_layout, :initialize_paginator, :only => :index
  before_filter :initialize_lesson_destination, :only => [:add, :copy, :like, :remove, :dislike, :destroy, :publish, :unpublish]
  
  # ### Description
  #
  # Main page of the section 'lessons'. When it's called via ajax it's because of the application of filters, paginations, or after an operation that changed the number of items in the page.
  #
  # ### Mode
  #
  # Html + Ajax
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_layout
  # * LessonsController#initialize_paginator
  #
  def index
    get_own_lessons
    if @page > @pages_amount && @pages_amount != 0
      @page = @pages_amount
      get_own_lessons
    end
    render_js_or_html_index
  end
  
  # ### Description
  #
  # Adds a link of this lesson to your section.
  # * *found*: reloads the lesson in compact mode
  # * *compact*: <i>[this action doesn't occur]</i>
  # * *expanded*: removes the lesson and reloads the whole page
  #
  # ### Mode
  #
  # Ajax + Json
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_lesson
  # * ApplicationController#initialize_lesson_destination
  #
  def add
    @ok_msg = t('other_popup_messages.correct.add.lesson')
    if @ok
      if !current_user.bookmark('Lesson', @lesson_id)
        @ok = false
        @error = I18n.t('activerecord.errors.models.bookmark.problem_creating_for_lesson')
      end
    else
      @error = I18n.t('activerecord.errors.models.bookmark.problem_creating_for_lesson')
    end
    if @destination == ButtonDestinations::FOUND_LESSON
      prepare_lesson_for_js
      @ok_msg = nil
      render 'lessons/reload_compact.js'
    else
      render :json => {:ok => @ok, :msg => (@ok ? @ok_msg : @error)}
    end
  end
  
  # ### Description
  #
  # Creates a copy of this lesson, and opens a popup asking you if you want to edit immediately the new lesson or reload the page
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * LessonsController#check_available_for_user
  # * ApplicationController#initialize_lesson
  # * ApplicationController#initialize_lesson_destination
  #
  def copy
    if @ok
      @new_lesson = @lesson.copy(current_user.id)
      if @new_lesson.nil?
        @ok = false
        @error = @lesson.get_base_error
      end
    else
      @error = I18n.t('activerecord.errors.models.lesson.problem_copying')
    end
  end
  
  # ### Description
  #
  # Deletes definitively a lesson.
  # * *found*: removes the lesson and reloads the whole page
  # * *compact*: removes the lesson and reloads the whole page
  # * *expanded*: <i>[this action doesn't occur]</i>
  #
  # ### Mode
  #
  # Json
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_lesson_with_owner
  # * ApplicationController#initialize_lesson_destination
  #
  def destroy
    if @ok
      if !@lesson.destroy_with_notifications
        @ok = false
        @error = @lesson.get_base_error
      end
    else
      @error = I18n.t('activerecord.errors.models.lesson.problem_destroying')
    end
    render :json => {:ok => @ok, :msg => @error}
  end
  
  # ### Description
  #
  # Removes your 'I like it' from the lesson
  # * *found*: reloads the lesson in compact mode
  # * *compact*: reloads the lesson in compact mode
  # * *expanded*: reloads the lesson in expanded mode
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_lesson
  # * ApplicationController#initialize_lesson_destination
  #
  def dislike
    if @ok
      if !current_user.dislike(@lesson_id)
        @ok = false
        @error = I18n.t('activerecord.errors.models.like.problem_destroying')
      end
    else
      @error = I18n.t('activerecord.errors.models.like.problem_destroying')
    end
    prepare_lesson_for_js
    if [ButtonDestinations::FOUND_LESSON, ButtonDestinations::COMPACT_LESSON].include? @destination
      render 'lessons/reload_compact.js'
    else
      render 'lessons/reload_expanded.js'
    end
  end
  
  # ### Description
  #
  # Records a 'I like it' on the lesson
  # * *found*: reloads the lesson in compact mode
  # * *compact*: reloads the lesson in compact mode
  # * *expanded*: reloads the lesson in expanded mode
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_lesson
  # * ApplicationController#initialize_lesson_destination
  #
  def like
    if @ok
      if !current_user.like(@lesson_id)
        @ok = false
        @error = I18n.t('activerecord.errors.models.like.problem_creating')
      end
    else
      @error = I18n.t('activerecord.errors.models.like.problem_creating')
    end
    prepare_lesson_for_js
    if [ButtonDestinations::FOUND_LESSON, ButtonDestinations::COMPACT_LESSON].include? @destination
      render 'lessons/reload_compact.js'
    else
      render 'lessons/reload_expanded.js'
    end
  end
  
  # ### Description
  #
  # Calls Lesson#publish on the lesson.
  # * *found*: reloads the lesson in compact mode
  # * *compact*: reloads the lesson in compact mode
  # * *expanded*: <i>[this action doesn't occur]</i>
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * LessonsController#check_available_for_user
  # * ApplicationController#initialize_lesson_with_owner
  # * ApplicationController#initialize_lesson_destination
  #
  def publish
    if current_user.trial?
      @ok = false
      @error = t('registration.trial_limitations_messages.cant_publish_lesson')
    else
      @ok_msg = t('other_popup_messages.correct.publish')
      if @ok
        if !@lesson.publish
          @ok = false
          @error = @lesson.get_base_error
        end
      else
        @error = I18n.t('activerecord.errors.models.lesson.problem_publishing')
      end
      prepare_lesson_for_js
    end
    if [ButtonDestinations::FOUND_LESSON, ButtonDestinations::COMPACT_LESSON].include? @destination
      render 'lessons/reload_compact.js'
    else
      render 'lessons/reload_expanded.js'
    end
  end
  
  # ### Description
  #
  # Calls Lesson#unpublish on the lesson.
  # * *found*: reloads the lesson in compact mode
  # * *compact*: reloads the lesson in compact mode
  # * *expanded*: <i>[this action doesn't occur]</i>
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_lesson_with_owner
  # * ApplicationController#initialize_lesson_destination
  #
  def unpublish
    @ok_msg = t('other_popup_messages.correct.unpublish')
    if @ok
      if !@lesson.unpublish
        @ok = false
        @error = @lesson.get_base_error
      end
    else
      @error = I18n.t('activerecord.errors.models.lesson.problem_unpublishing')
    end
    prepare_lesson_for_js
    if [ButtonDestinations::FOUND_LESSON, ButtonDestinations::COMPACT_LESSON].include? @destination
      render 'lessons/reload_compact.js'
    else
      render 'lessons/reload_expanded.js'
    end
  end
  
  # ### Description
  #
  # Removes the link of this lesson from your section.
  # * *found*: reloads the lesson in compact mode
  # * *compact*: removes the lesson and reloads the whole page
  # * *expanded*: <i>[this action doesn't occur]</i>
  #
  # ### Mode
  #
  # Ajax + Json
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_lesson
  # * ApplicationController#initialize_lesson_destination
  #
  def remove
    @ok_msg = t('other_popup_messages.correct.remove.lesson')
    if @ok
      bookmark = Bookmark.where(:user_id => current_user.id, :bookmarkable_type => 'Lesson', :bookmarkable_id => @lesson_id).first
      if bookmark.nil?
        @ok = false
        @error = I18n.t('activerecord.errors.models.bookmark.problem_destroying_for_lesson')
      else
        bookmark.destroy
        if Bookmark.where(:user_id => current_user.id, :bookmarkable_type => 'Lesson', :bookmarkable_id => @lesson_id).any?
          @ok = false
          @error = I18n.t('activerecord.errors.models.bookmark.problem_destroying_for_lesson')
        end
      end
    else
      @error = I18n.t('activerecord.errors.models.bookmark.problem_destroying_for_lesson')
    end
    if @destination == ButtonDestinations::FOUND_LESSON
      prepare_lesson_for_js
      render 'lessons/reload_compact.js'
    else
      render :json => {:ok => @ok, :msg => (@ok ? @ok_msg : @error)}
    end
  end
  
  # ### Description
  #
  # Sends a notification about the details of the modification and sets the lesson as *notified* (using Lesson#notify_changes)
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_lesson_with_owner
  #
  def notify_modification
    if @ok
      msg = params[:details_placeholder].blank? ? '' : params[:details]
      @lesson.notify_changes msg
    end
  end
  
  # ### Description
  #
  # Doesn't send any notification and sets the lesson as *notified* (using Lesson#dont_notify_changes)
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_lesson_with_owner
  #
  def dont_notify_modification
    if @ok
      @lesson.dont_notify_changes
      render :nothing => true
    end
  end
  
  private
  
  # Checks if the lesson is available (it doesn't contain any audio or video in conversion)
  def check_available_for_user
    l = Lesson.find_by_id params[:lesson_id]
    if l && !l.available?
      render :nothing => true
      return
    end
  end
  
  # Gets the lessons using User#own_lessons
  def get_own_lessons
    current_user_own_lessons = current_user.own_lessons(@page, @for_page, @filter)
    @lessons = current_user_own_lessons[:records]
    @pages_amount = current_user_own_lessons[:pages_amount]
    @covers = current_user_own_lessons[:covers]
  end
  
  # Initializes pagination parameters and filters
  def initialize_paginator
    @page = correct_integer?(params[:page]) ? params[:page].to_i : 1
    @for_page = FOR_PAGE
    @filter = params[:filter]
    @filter = Filters::ALL_LESSONS if !Filters::LESSONS_SET.include?(@filter)
  end
  
end

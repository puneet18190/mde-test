# ### Description
#
# Contains all the actions related with the user's Virtual Classroom
#
# ### Models used
#
# * VirtualClassroomLesson
# * Lesson
# * Notification
#
class VirtualClassroomController < ApplicationController
  
  # Number of lessons in a page of the Virtual Classroom (configured in settings.yml)
  FOR_PAGE = SETTINGS['lessons_for_page_in_virtual_classroom']
  
  # Number of lessons in the first block of the quick loader (configured in settings.yml)
  LESSONS_IN_QUICK_LOADER = SETTINGS['lessons_in_quick_loader']
  
  before_filter :initialize_lesson, :only => [:add_lesson, :remove_lesson, :remove_lesson_from_inside]
  before_filter :initialize_lesson_destination, :only => [:add_lesson, :remove_lesson]
  before_filter :initialize_layout, :initialize_paginator, :only => :index
  before_filter :initialize_virtual_classroom_lesson, :only => [:add_lesson_to_playlist, :remove_lesson_from_playlist, :change_position_in_playlist]
  before_filter :initialize_position, :only => :change_position_in_playlist
  before_filter :initialize_lesson_for_sending_link, :only => :send_link
  before_filter :initialize_emails, :only => :send_link
  before_filter :initialize_page, :only => :select_lessons_new_block
  before_filter :initialize_loaded_lessons, :only => :load_lessons
  layout 'virtual_classroom'
  
  # ### Description
  #
  # Main page of the section 'Virtual Classroom'. When it's called via ajax it's because of the application of filters, paginations, or after an operation that changed the number of items in the page.
  #
  # ### Mode
  #
  # Html + Ajax
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_layout
  # * VirtualClassroomController#initialize_paginator
  #
  def index
    get_lessons
    if @page > @pages_amount && @pages_amount != 0
      @page = @pages_amount
      get_lessons
    end
    @playlist = current_user.playlist
    @mailing_list_groups = current_user.own_mailing_list_groups
    @emptier = current_user.own_lessons(1, LESSONS_IN_QUICK_LOADER, Filters::ALL_LESSONS, true)[:records].empty?
    render_js_or_html_index
  end
  
  # ### Description
  #
  # Creates a link of this lesson into your Virtual Classroom. List of possible graphical effects (see LessonsController and ButtonDestinations for more details):
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
  # * ApplicationController#initialize_lesson
  # * ApplicationController#initialize_lesson_destination
  #
  def add_lesson
    if @ok
      if !@lesson.add_to_virtual_classroom(current_user.id)
        @ok = false
        @error = @lesson.get_base_error
      end
    else
      @error = I18n.t('activerecord.errors.models.lesson.problem_adding_to_virtual_classroom')
    end
    prepare_lesson_for_js
    render 'lessons/reload_compact.js'
  end
  
  # ### Description
  #
  # Removes the link of this lesson from your Virtual Classroom. List of possible graphical effects (see LessonsController and ButtonDestinations for more details):
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
  # * ApplicationController#initialize_lesson
  # * ApplicationController#initialize_lesson_destination
  #
  def remove_lesson
    if @ok
      if !@lesson.remove_from_virtual_classroom(current_user.id)
        @ok = false
        @error = @lesson.get_base_error
      end
    else
      @error = I18n.t('activerecord.errors.models.lesson.problem_removing_from_virtual_classroom')
    end
    prepare_lesson_for_js
    render 'lessons/reload_compact.js'
  end
  
  # ### Description
  #
  # Removes the lesson from your Virtual Classroom while you are inside the Virtual Classroom itself
  #
  # ### Mode
  #
  # Json
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_lesson
  #
  def remove_lesson_from_inside
    if @ok
      if !@lesson.remove_from_virtual_classroom(current_user.id)
        @ok = false
        @error = @lesson.get_base_error
      end
    else
      @error = I18n.t('activerecord.errors.models.lesson.problem_removing_from_virtual_classroom')
    end
    render :json => {:ok => @ok, :msg => @error}
  end
  
  # ### Description
  #
  # Adds a lesson to your playlist
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * VirtualClassroomController#initialize_virtual_classroom_lesson
  #
  def add_lesson_to_playlist
    if @ok
      if @virtual_classroom_lesson.add_to_playlist
        @playlist = current_user.playlist
      else
        @ok = false
        @error = @virtual_classroom_lesson.get_base_error
      end
    else
      @error = I18n.t('activerecord.errors.models.virtual_classroom_lesson.problem_adding_to_playlist')
    end
  end
  
  # ### Description
  #
  # Removes a lesson from the playlist
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * VirtualClassroomController#initialize_virtual_classroom_lesson
  #
  def remove_lesson_from_playlist
    if @ok
      if @virtual_classroom_lesson.remove_from_playlist
        @playlist = current_user.playlist
      else
        @ok = false
        @error = @virtual_classroom_lesson.get_base_error
      end
    else
      @error = I18n.t('activerecord.errors.models.virtual_classroom_lesson.problem_removing_from_playlist')
    end
  end
  
  # ### Description
  #
  # Moves the lesson into a different position inside the playlist
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * VirtualClassroomController#initialize_virtual_classroom_lesson
  # * ApplicationController#initialize_position
  #
  def change_position_in_playlist
    if @ok
      if !@virtual_classroom_lesson.change_position(@position)
        @ok = false
        @error = @virtual_classroom_lesson.get_base_error
      end
    else
      @error = I18n.t('activerecord.errors.models.virtual_classroom_lesson.problem_changing_position_in_playlist')
    end
    @playlist = current_user.playlist
  end
  
  # ### Description
  #
  # Empties the playlist and reloads it
  #
  # ### Mode
  #
  # Ajax
  #
  def empty_playlist
    @ok = current_user.empty_playlist
    @error = I18n.t('activerecord.errors.models.virtual_classroom_lesson.problem_emptying_playlist') if !@ok
  end
  
  # ### Description
  #
  # Empties the Virtual Classroom and reloads it
  #
  # ### Mode
  #
  # Ajax
  #
  def empty_virtual_classroom
    current_user.empty_virtual_classroom
  end
  
  # ### Description
  #
  # Opens a window that contains the list of your lessons: you can pick multiple lessons and add them directly into your Virtual Classroom
  #
  # ### Mode
  #
  # Ajax
  #
  def select_lessons
    x = current_user.own_lessons(1, LESSONS_IN_QUICK_LOADER, Filters::ALL_LESSONS, true)
    @lessons = x[:records]
    @tot_pages = x[:pages_amount]
    @covers = x[:covers]
  end
  
  # ### Description
  #
  # Gets a new block of the list initialized in VirtualClassroomController#select_lessons
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * VirtualClassroomController#initialize_page
  #
  def select_lessons_new_block
    if @ok
      x = current_user.own_lessons(@page, LESSONS_IN_QUICK_LOADER, Filters::ALL_LESSONS, true)
      @lessons = x[:records]
      @covers = x[:covers]
    end
  end
  
  # ### Description
  #
  # From the list initialized in VirtualClassroomController#select_lessons, load lessons into the Virtual Classroom
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # VirtualClassroomController#initialize_loaded_lessons
  #
  def load_lessons
    @loaded = 0
    @load_lessons.each do |l|
      @loaded += 1 if l.add_to_virtual_classroom(current_user.id)
    end
    initialize_paginator
    get_lessons
  end
  
  # ### Description
  #
  # Sends a link containing the public url of a lesson to a list of emails (see MailingListGroup)
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * VirtualClassroomController#initialize_lesson_for_sending_link
  # * VirtualClassroomController#initialize_emails
  #
  def send_link
    if current_user.trial?
      render :nothing => true
      return
    end
    if @ok
      UserMailer.see_my_lesson(@emails, current_user, @lesson, @message).deliver
      string_emails = ''
      @emails.each do |em|
        string_emails = "#{string_emails} '#{em}',"
      end
      string_emails.chop!
      Notification.send_to(
        current_user.id,
        I18n.t('notifications.lessons.link_sent.title'),
        I18n.t('notifications.lessons.link_sent.message', :title => @lesson.title, :message => @message, :emails => string_emails),
        ''
      )
    end
  end
  
  private
  
  # Initializes the lesson and checks that it's in the Virtual Classroom
  def initialize_lesson_for_sending_link
    initialize_lesson
    update_ok(!@lesson.nil? && @lesson.in_virtual_classroom?(current_user.id))
  end
  
  # Initializes the lessons just loaded in the multiple loader
  def initialize_loaded_lessons
    @load_lessons = []
    param_name = 'virtual_classroom_quick_loaded_lesson_name'
    params.each do |k, v|
      k_last = k.split('_').last
      if k.gsub("_#{k_last}", '') == param_name && correct_integer?(k_last) && v == '1'
        lesson = Lesson.find_by_id(k_last.to_i)
        @load_lessons << lesson if !lesson.nil?
      end
    end
  end
  
  # Initializes the page parameter
  def initialize_page
    @page = correct_integer?(params[:page]) ? params[:page].to_i : 0
    update_ok(@page > 0)
  end
  
  # Initializes the list of the emails, from a mix of single emails and mailing lists (see MailingListGroup)
  def initialize_emails
    emails_hash = {}
    @original_emails_number = params[:emails].split(',').length
    params[:emails].split(',').each do |email|
      emails_hash[email] = true if !(/^([0-9a-zA-Z].*?@([0-9a-zA-Z].*\.\w{2,4}))$/ =~ email).nil?
    end
    @emails = emails_hash.keys
    @message = params[:message_placeholer].blank? ? '' : params[:message]
    @message = @message.blank? ? I18n.t('virtual_classroom.send_link.empty_message') : @message[0, I18n.t('language_parameters.notification.message_length_for_send_lesson_link')]
    update_ok(@emails.any?)
  end
  
  # Initializes a lesson for the Virtual Classroom (checks that it's included in the section 'lessons' of the current user)
  def initialize_virtual_classroom_lesson
    @lesson_id = correct_integer?(params[:lesson_id]) ? params[:lesson_id].to_i : 0
    @virtual_classroom_lesson = VirtualClassroomLesson.where(:lesson_id => @lesson_id, :user_id => current_user.id).first
    update_ok(!@virtual_classroom_lesson.nil?)
  end
  
  # Gets lessons, using User#full_virtual_classroom
  def get_lessons
    current_user_virtual_classroom_lessons = current_user.full_virtual_classroom(@page, @for_page)
    @lessons = current_user_virtual_classroom_lessons[:records]
    @pages_amount = current_user_virtual_classroom_lessons[:pages_amount]
    @covers = current_user_virtual_classroom_lessons[:covers]
  end
  
  # Initializes paginator parameters
  def initialize_paginator
    @page = correct_integer?(params[:page]) ? params[:page].to_i : 1
    @for_page = FOR_PAGE
  end
  
end

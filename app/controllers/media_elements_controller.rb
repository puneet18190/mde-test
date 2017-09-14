# ### Description
#
# Controller for all the actions related to elements and their buttons. All over this controller we use the constant keywords defined in ButtonDestinations, namely:
# 1. *found_media_element* (or simply *found*) for a media element seen in a results list of the search engine
# 2. *compact_media_element* (or simply *compact*) for a media element seen in the compact mode
# 3. *expanded_media_element* (or simply *expanded*) for a media element seen in expanded mode (this happens only in the dashboard, see DashboardController)
#
# ### Models used
#
# * MediaElement
# * Notification
# * User
#
class MediaElementsController < ApplicationController
  
  # Default number of elements in compact mode to be shown in a single page
  FOR_PAGE = 8
  
  before_filter :initialize_media_element, :only => [:add, :remove]
  before_filter :initialize_media_element_with_owner, :only => :destroy
  before_filter :initialize_media_element_with_owner_and_private, :only => :update
  before_filter :initialize_layout, :initialize_paginator, :only => :index
  before_filter :initialize_media_element_destination, :only => [:add, :remove, :destroy, :destroy_fake]
  
  if SETTINGS['media_test']
    
    skip_before_filter :authenticate, :initialize_location, :initialize_players_counter, :only => [:videos_test, :audios_test]
    before_filter :admin_authenticate, :only => [:videos_test, :audios_test]
    layout false, :only => [:videos_test, :audios_test]
    
    # ### Description
    #
    # Test useful to check correctness of conversion and cross browser visibility of all elements of kind Video
    #
    # ### Mode
    #
    # Html
    #
    # ### Specific filters
    #
    # * ApplicationController#admin_authenticate
    #
    # ### Skipped filters
    #
    # * ApplicationController#authenticate
    # * ApplicationController#initialize_location
    # * ApplicationController#initialize_players_counter
    #
    def videos_test
    end
    
    # ### Description
    #
    # Test useful to check correctness of conversion and cross browser visibility of all elements of kind Audio
    #
    # ### Mode
    #
    # Html
    #
    # ### Specific filters
    #
    # * ApplicationController#admin_authenticate
    #
    # ### Skipped filters
    #
    # * ApplicationController#authenticate
    # * ApplicationController#initialize_location
    # * ApplicationController#initialize_players_counter
    #
    def audios_test
    end
    
  end
  
  # ### Description
  #
  # Main page of the section 'elements'. When it's called via ajax it's because of the application of filters, paginations, or after an operation that changed the number of items in the page.
  #
  # ### Mode
  #
  # Html + Ajax
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_layout
  # * MediaElementsController#initialize_paginator
  #
  def index
    get_own_media_elements
    if @page > @pages_amount && @pages_amount != 0
      @page = @pages_amount
      get_own_media_elements
    end
    render_js_or_html_index
  end
  
  # ### Description
  #
  # Opens the general page of the elements editor:
  # * the *video* icon redirects to VideoEditorController#new
  # * the *audio* icon redirects to AudioEditorController#new
  # * the *image* icon redirects to GalleriesController#image_for_image_editor (and successively to ImageEditorController#edit)
  #
  # ### Mode
  #
  # Html
  #
  def new
    render :layout => 'media_element_editor'
  end
  
  # ### Description
  #
  # This action checks for errors without setting the media on the new element
  #
  # ### Mode
  #
  # Js
  #
  def create_fake
    record = MediaElement.new
    record.title = params[:title_placeholder] != '0' ? '' : params[:title]
    record.description = params[:description_placeholder] != '0' ? '' : params[:description]
    record.tags = params[:tags_value]
    record.user_id = current_user.id
    record.save_tags = true
    record.valid?
    @errors = convert_media_element_error_messages record.errors
    @errors[:media] = t('forms.error_captions.media_file_too_large').downcase
  end
  
  # ### Description
  #
  # Action that calls the uploader, casts the type, and creates the new element
  #
  # ### Mode
  #
  # Html
  #
  def create
    media = params[:media]
    record = MediaElement.new :media => media
    record.title = params[:title_placeholder] != '0' ? '' : params[:title]
    record.description = params[:description_placeholder] != '0' ? '' : params[:description]
    record.tags = params[:tags_value]
    record.user_id = current_user.id
    record.save_tags = true
    if record.save
      if !record.image?
        Notification.send_to(
          current_user.id,
          I18n.t("notifications.#{record.class.to_s.downcase}.upload.started.title"),
          I18n.t("notifications.#{record.class.to_s.downcase}.upload.started.message", :item => record.title),
          ''
        )
      end
    else
      if record.errors.added? :media, :too_large
        return render :file => Rails.root.join('public/413.html'), :layout => false, :status => 413
      end
      @errors = convert_media_element_error_messages record.errors
    end
    render :layout => false
  end
  
  # ### Description
  #
  # Adds a link of this element to your section.
  # * *found*: reloads the element in compact mode
  # * *compact*: <i>[this action doesn't occur]</i>
  # * *expanded*: removes the element and reloads the whole page
  #
  # ### Mode
  #
  # Ajax + Json
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_media_element
  # * ApplicationController#initialize_media_element_destination
  #
  def add
    @ok_msg = t('other_popup_messages.correct.add.media_element')
    if @ok
      if !current_user.bookmark('MediaElement', @media_element_id)
        @ok = false
        @error = I18n.t('activerecord.errors.models.bookmark.problem_creating_for_media_element')
      end
    else
      @error = I18n.t('activerecord.errors.models.bookmark.problem_creating_for_media_element')
    end
    if @destination == ButtonDestinations::FOUND_MEDIA_ELEMENT
      prepare_media_element_for_js
      @ok_msg = nil
      render 'media_elements/reload.js'
    else
      render :json => {:ok => @ok, :msg => (@ok ? @ok_msg : @error)}
    end
  end
  
  # ### Description
  #
  # Deletes definitively an element.
  # * *found*: removes the element and reloads the whole page
  # * *compact*: removes the element and reloads the whole page
  # * *expanded*: removes the element and reloads the whole page
  #
  # ### Mode
  #
  # Json
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_media_element_with_owner
  # * ApplicationController#initialize_media_element_destination
  #
  def destroy
    if @ok
      if !@media_element.check_and_destroy
        @ok = false
        @error = @media_element.get_base_error
      end
    else
      @error = I18n.t('activerecord.errors.models.media_element.problem_destroying')
    end
    render :json => {:ok => @ok, :msg => @error}
  end
  
  # ### Description
  #
  # Removes the link of this element from your section.
  # * *found*: reloads the element in compact mode
  # * *compact*: removes the element and reloads the whole page
  # * *expanded*: removes the element and reloads the whole page
  #
  # ### Mode
  #
  # Ajax + Json
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_media_element
  # * ApplicationController#initialize_media_element_destination
  #
  def remove
    @ok_msg = t('other_popup_messages.correct.remove.media_element')
    if @ok
      bookmark = Bookmark.where(:user_id => current_user.id, :bookmarkable_type => 'MediaElement', :bookmarkable_id => @media_element_id).first
      if bookmark.nil?
        @ok = false
        @error = I18n.t('activerecord.errors.models.bookmark.problem_destroying_for_media_element')
      else
        bookmark.destroy
        if Bookmark.where(:user_id => current_user.id, :bookmarkable_type => 'MediaElement', :bookmarkable_id => @media_element_id).any?
          @ok = false
          @error = I18n.t('activerecord.errors.models.bookmark.problem_destroying_for_media_element')
        end
      end
    else
      @error = I18n.t('activerecord.errors.models.bookmark.problem_destroying_for_media_element')
    end
    if @destination == ButtonDestinations::FOUND_MEDIA_ELEMENT
      prepare_media_element_for_js
      render 'media_elements/reload.js'
    else
      render :json => {:ok => @ok, :msg => (@ok ? @ok_msg : @error)}
    end
  end
  
  # ### Description
  #
  # Updates the general information of the element (title, description and tags)
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_media_element_with_owner_and_private
  #
  def update
    if @ok
      @media_element.title = params[:title]
      @media_element.description = params[:description]
      @media_element.tags = params[:tags_value]
      @media_element.save_tags = true
      if !@media_element.save
        @errors = convert_media_element_error_messages @media_element.errors
      else
        @media_element.set_status current_user.id
      end
    end
  end
  
  # ### Description
  #
  # Loads the preview of the element (to be shown inside a special popup)
  #
  # ### Mode
  #
  # Ajax
  #
  def load_preview
    @media_element_id = correct_integer?(params[:media_element_id]) ? params[:media_element_id].to_i : 0
    @media_element = MediaElement.find_by_id @media_element_id
    if !@media_element.nil? && (@media_element.is_public || @media_element.user_id == current_user.id) && @media_element.converted
      @ok = true
      @media_element.set_status current_user.id
    else
      @ok = false
    end
  end
  
  # ### Description
  #
  # Reloads the element if it's in conversion
  #
  # ### Mode
  #
  # Ajax
  #
  def check_conversion
    @mes = []
    params.keys.each do |key|
      if key[0, 2] == 'me'
        id = key[2, key.length - 2]
        media_element_id = correct_integer?(id) ? id.to_i : 0
        media_element = MediaElement.find_by_id media_element_id
        ok = (media_element && current_user.id == media_element.user_id && !media_element.is_public)
        media_element.set_status current_user.id if ok
        @mes << {
          :ok               => ok,
          :media_element_id => media_element_id,
          :media_element    => media_element
        }
      end
    end
  end
  
  # ### Description
  #
  # Deletes an element which has not been correctly converted
  #
  # ### Mode
  #
  # Json
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_media_element_destination
  #
  def destroy_fake
    render :json => {:ok => true, :msg => nil}
  end
  
  private
  
  # Gets media elements using User#own_media_elements
  def get_own_media_elements
    current_user_own_media_elements = current_user.own_media_elements(@page, @for_page, @filter)
    @media_elements = current_user_own_media_elements[:records]
    @pages_amount = current_user_own_media_elements[:pages_amount]
  end
  
  # Initializes pagination parameters and filters
  def initialize_paginator
    @page = correct_integer?(params[:page]) ? params[:page].to_i : 1
    @display = [MediaElement::DISPLAY_MODES[:compact], MediaElement::DISPLAY_MODES[:expanded]].include?(params[:display]) ? params[:display] : MediaElement::DISPLAY_MODES[:expanded]
    if @display == MediaElement::DISPLAY_MODES[:expanded]
      @for_row = correct_integer?(params[:for_row]) ? params[:for_row].to_i : 1
      @for_row = 1 if @for_row > 50
      @for_page = @for_row * 2
    else
      @for_page = FOR_PAGE
    end
    @filter = params[:filter]
    @filter = Filters::ALL_MEDIA_ELEMENTS if !Filters::MEDIA_ELEMENTS_SET.include?(@filter)
    @just_resizing = params[:resizing].present?
  end
  
end

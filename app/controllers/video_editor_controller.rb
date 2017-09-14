require 'media/video/editing/composer/job'

# ### Description
#
# Controller for all the actions in the video editor
#
# ### Models used
#
# * Video
# * Notification
#
class VideoEditorController < ApplicationController
  
  before_filter :check_available_for_user
  before_filter :initialize_video_with_owner_or_public, :only => :edit
  before_filter :extract_cache, :only => [:edit, :new, :restore_cache]
  layout 'media_element_editor'
  
  # ### Description
  #
  # Opens the video editor with only one component, corresponding to a given video
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * VideoEditorController#check_available_for_user
  # * VideoEditorController#initialize_video_with_owner_or_public
  # * VideoEditorController#extract_cache
  #
  def edit
    if @ok
      @edited_video = @video
      @parameters = convert_video_to_parameters
      @total_length = Video.total_prototype_time(@parameters)
      @used_in_private_lessons = used_in_private_lessons
      @back = params[:back] if params[:back].present?
    else
      redirect_to dashboard_path
      return
    end
  end
  
  # ### Description
  #
  # Opens the video editor empty
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * VideoEditorController#check_available_for_user
  # * VideoEditorController#extract_cache
  #
  def new
    @parameters = empty_parameters
    @total_length = Video.total_prototype_time(@parameters)
    @used_in_private_lessons = used_in_private_lessons
    @back = params[:back] if params[:back].present?
    render :edit
  end
  
  # ### Description
  #
  # Opens the video editor restoring the cache (if there is no cache, the Editor is empty but there is no redirection to VideoEditorController#new)
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * VideoEditorController#check_available_for_user
  # * VideoEditorController#extract_cache
  #
  def restore_cache
    @parameters = @cache.nil? ? empty_parameters : @cache
    @cache = nil
    @total_length = Video.total_prototype_time(@parameters)
    @used_in_private_lessons = used_in_private_lessons
    render :edit
  end
  
  # ### Description
  #
  # Empties the cache
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * VideoEditorController#check_available_for_user
  #
  def empty_cache
    current_user.video_editor_cache!
    render :nothing => true
  end
  
  # ### Description
  #
  # Saves the cache
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * VideoEditorController#check_available_for_user
  #
  def save_cache
    current_user.video_editor_cache! extract_form_parameters
    render :nothing => true
  end
  
  # ### Description
  #
  # Saves the work as a new video
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * VideoEditorController#check_available_for_user
  #
  def save
    params_with_standard_keys('new')
    parameters = Video.convert_to_primitive_parameters(extract_form_parameters, current_user.id)
    @redirect = false
    if parameters.nil?
      current_user.video_editor_cache!
      @redirect = true
      render 'media_elements/info_form_in_editor/save'
      return
    end
    record = Video.new do |r|
      r.title       = params[:title_placeholder] != '0' ? '' : params[:title]
      r.description = params[:description_placeholder] != '0' ? '' : params[:description]
      r.tags        = params[:tags]
      r.user_id     = current_user.id
      r.composing   = true
      r.save_tags = true
    end
    if record.save
      parameters[:initial_video] = {:id => record.id}
      Notification.send_to(
        current_user.id,
        I18n.t('notifications.video.compose.create.started.title'),
        I18n.t('notifications.video.compose.create.started.message', :item => record.title),
        ''
      )
      Delayed::Job.enqueue Media::Video::Editing::Composer::Job.new(parameters)
    else
      @errors = convert_media_element_error_messages(record.errors)
    end
    render 'media_elements/info_form_in_editor/save'
  end
  
  # ### Description
  #
  # Saves the work overwriting an existing video
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * VideoEditorController#check_available_for_user
  #
  def overwrite
    params_with_standard_keys('edit')
    parameters = Video.convert_to_primitive_parameters(extract_form_parameters, current_user.id)
    @redirect = false
    if parameters.nil?
      current_user.video_editor_cache!
      @redirect = true
      render 'media_elements/info_form_in_editor/save'
      return
    end
    record = Video.find_by_id parameters[:initial_video]
    record.title = params[:title]
    record.description = params[:description]
    record.tags = params[:tags]
    record.save_tags = true
    if record.valid?
      parameters[:initial_video] = {
        :id => parameters[:initial_video],
        :title => params[:title],
        :description => params[:description],
        :tags => params[:tags]
      }
      record.overwrite!
      Notification.send_to(
        current_user.id,
        I18n.t('notifications.video.compose.update.started.title'),
        I18n.t('notifications.video.compose.update.started.message', :item => record.title),
        ''
      )
      Delayed::Job.enqueue Media::Video::Editing::Composer::Job.new(parameters)
    else
      @errors = convert_media_element_error_messages(record.errors)
    end
    render 'media_elements/info_form_in_editor/save'
  end
  
  private
  
  # Sets the variable params[] with the regular keys like :title, :description, :tags
  def params_with_standard_keys(scope)
    params[:title] = params[:"#{scope}_title"]
    params[:description] = params[:"#{scope}_description"]
    params[:tags] = params[:"#{scope}_tags"]
  end
  
  # Checks if the video is being used in private lessons
  def used_in_private_lessons
    return false if @parameters[:initial_video].nil?
    @parameters[:initial_video].media_elements_slides.any?
  end
  
  # Checks if the video editor is available for the user (see User#video_editor_available)
  def check_available_for_user
    if !current_user.video_editor_available
      render 'not_available'
      return
    end
  end
  
  # Extracts parameters from the form, and converts them into the format of Media::Video::Editing::Parameters
  def extract_single_form_parameter(p, value)
    if ['type', 'content', 'background_color', 'text_color'].include? p
      return value
    elsif ['position', 'video_id', 'image_id', 'from', 'to', 'duration'].include? p
      return value.to_i
    else
      return nil
    end
  end
  
  def extract_form_parameters
    unordered_resp = {}
    ordered_resp = {}
    resp = {
      :initial_video_id => params[:initial_video_id].blank? ? nil : params[:initial_video_id].to_i,
      :audio_id => params[:audio_id].blank? ? nil : params[:audio_id].to_i,
      :components => []
    }
    params.each do |k, v|
      if !(k =~ /_/).nil?
        index = k.split('_').last.to_i
        p = k.gsub("_#{index}", '')
        if ['type', 'video_id', 'image_id', 'from', 'to', 'position', 'content', 'background_color', 'text_color', 'duration'].include?(p)
          if unordered_resp.has_key? index
            unordered_resp[index][:"#{p}"] = extract_single_form_parameter(p, v)
          else
            unordered_resp[index] = {:"#{p}" => extract_single_form_parameter(p, v)}
          end
        end
      end
    end
    unordered_resp.each do |k, v|
      ordered_resp[v[:position]] = v
      ordered_resp[v[:position]].delete(:position)
    end
    ordered_resp.sort.each do |item|
      resp[:components] << item[1]
    end
    resp
  end
  
  # Converts a single video in a cache in the format of Media::Video::Editing::Parameters
  def convert_video_to_parameters
    resp = {}
    resp[:initial_video_id] = @video.is_public ? nil : @video.id
    resp[:audio_id] = nil
    resp[:components] = [{}]
    resp[:components].first[:type] = Media::Video::Editing::Parameters::VIDEO_COMPONENT
    resp[:components].first[:video_id] = @video.id
    resp[:components].first[:from] = 0
    resp[:components].first[:to] = @video.min_duration
    resp = Video.convert_parameters(resp, current_user.id)
    resp.nil? ? empty_parameters : resp
  end
  
  # Gets a set of parameters in the format of Media::Video::Editing::Parameters from an empty video editor
  def empty_parameters
    resp = {}
    resp[:initial_video] = nil
    resp[:audio_track] = nil
    resp[:components] = []
    resp
  end
  
  # Extracts the cache and converts it
  def extract_cache
    @cache = Video.convert_parameters current_user.video_editor_cache, current_user.id
  end
  
  # Initializes the given video, and returns true if current_user owns it or it's public (these are the conditions for the user to visualize the video, but not modify it)
  def initialize_video_with_owner_or_public
    @video_id = correct_integer?(params[:video_id]) ? params[:video_id].to_i : 0
    @video = Video.find_by_id @video_id
    update_ok(!@video.nil? && (@video.is_public || current_user.id == @video.user_id))
  end
  
end

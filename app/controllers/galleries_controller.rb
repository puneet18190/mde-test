# ### Description
#
# List of actions to handle all the instances of galleries in the application. Since the gallery pagination is made with infinite scroll, for each gallery there is an action that extracts it first, and another one that gets a new block of elements. List of galleries for each section
# * lesson editor (see LessonEditorController):
#   * audio gallery
#     * GalleriesController#audio_for_lesson_editor
#     * GalleriesController#audio_for_lesson_editor_new_block
#   * image gallery
#     * GalleriesController#image_for_lesson_editor
#     * GalleriesController#image_for_lesson_editor_new_block
#   * video gallery
#     * GalleriesController#video_for_lesson_editor
#     * GalleriesController#video_for_lesson_editor_new_block
# * image editor (see ImageEditorController):
#   * image gallery
#     * GalleriesController#image_for_image_editor
#     * GalleriesController#image_for_image_editor_new_block
# * audio editor (see AudioEditorController):
#   * audio gallery
#     * GalleriesController#audio_for_audio_editor
#     * GalleriesController#audio_for_audio_editor_new_block
# * video editor (see VideoEditorController):
#   * mixed gallery (video + image + texts)
#     * GalleriesController#mixed_for_video_editor
#     * GalleriesController#mixed_for_video_editor_video_new_block
#     * GalleriesController#mixed_for_video_editor_image_new_block
#   * audio gallery
#     * GalleriesController#audio_for_video_editor
#     * GalleriesController#audio_for_video_editor_new_block
#
# ### Models used
#
# * User
# * Image
# * Audio
# * Video
#
class GalleriesController < ApplicationController
  
  # Number of images for page, configured in settings.yml
  IMAGES_FOR_PAGE = SETTINGS['images_for_page_in_gallery']
  
  # Number of audios for page, configured in settings.yml
  AUDIOS_FOR_PAGE = SETTINGS['audios_for_page_in_gallery']
  
  # Number of videos for page, configured in settings.yml
  VIDEOS_FOR_PAGE = SETTINGS['videos_for_page_in_gallery']
  
  # Number of documents for page, configured in settings.yml
  DOCUMENTS_FOR_PAGE = SETTINGS['documents_for_page_in_gallery']
  
  before_filter :initialize_page, :only => [
    :image_for_lesson_editor_new_block,
    :audio_for_lesson_editor_new_block,
    :video_for_lesson_editor_new_block,
    :mixed_for_video_editor_image_new_block,
    :mixed_for_video_editor_video_new_block,
    :audio_for_video_editor_new_block,
    :audio_for_audio_editor_new_block,
    :image_for_image_editor_new_block,
    :document_for_lesson_editor_new_block
  ]
  
  # ### Description
  #
  # Gets the first block of images for the lesson editor
  #
  # ### Mode
  #
  # Ajax
  #
  def image_for_lesson_editor
    get_images(1)
  end
  
  # ### Description
  #
  # Gets following blocks of images for the lesson editor
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * GalleriesController#initialize_page
  #
  def image_for_lesson_editor_new_block
    if @ok
      get_images(@page)
    else
      render :nothing => true
    end
  end
  
  # ### Description
  #
  # Gets the first block of audios for the lesson editor
  #
  # ### Mode
  #
  # Ajax
  #
  def audio_for_lesson_editor
    get_audios(1)
  end
  
  # ### Description
  #
  # Gets following blocks of audios for the lesson editor
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * GalleriesController#initialize_page
  #
  def audio_for_lesson_editor_new_block
    if @ok
      get_audios(@page)
    else
      render :nothing => true
    end
  end
  
  # ### Description
  #
  # Gets the first block of videos for the lesson editor
  #
  # ### Mode
  #
  # Ajax
  #
  def video_for_lesson_editor
    get_videos(1)
  end
  
  # ### Description
  #
  # Gets following blocks of videos for the lesson editor
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * GalleriesController#initialize_page
  #
  def video_for_lesson_editor_new_block
    if @ok
      get_videos(@page)
    else
      render :nothing => true
    end
  end
  
  # ### Description
  #
  # Gets the first block of videos and images for the video editor
  #
  # ### Mode
  #
  # Ajax
  #
  def mixed_for_video_editor
    get_images(1)
    @image_tot_pages = @tot_pages
    get_videos(1)
    @video_tot_pages = @tot_pages
  end
  
  # ### Description
  #
  # Gets following blocks of images for the video editor
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * GalleriesController#initialize_page
  #
  def mixed_for_video_editor_image_new_block
    if @ok
      get_images(@page)
    else
      render :nothing => true
    end
  end
  
  # ### Description
  #
  # Gets following blocks of videos for the video editor
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * GalleriesController#initialize_page
  #
  def mixed_for_video_editor_video_new_block
    if @ok
      get_videos(@page)
    else
      render :nothing => true
    end
  end
  
  # ### Description
  #
  # Gets the first block of audios for the video editor
  #
  # ### Mode
  #
  # Ajax
  #
  def audio_for_video_editor
    get_audios(1)
  end
  
  # ### Description
  #
  # Gets following blocks of audios for the video editor
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * GalleriesController#initialize_page
  #
  def audio_for_video_editor_new_block
    if @ok
      get_audios(@page)
    else
      render :nothing => true
    end
  end
  
  # ### Description
  #
  # Gets the first block of audios for the audio editor
  #
  # ### Mode
  #
  # Ajax
  #
  def audio_for_audio_editor
    get_audios(1)
  end
  
  # ### Description
  #
  # Gets following blocks of audios for the audio editor
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * GalleriesController#initialize_page
  #
  def audio_for_audio_editor_new_block
    if @ok
      get_audios(@page)
    else
      render :nothing => true
    end
  end
  
  # ### Description
  #
  # Gets the first block of images for the image editor: this is the only gallery with its own html page, since it is used only to get a new image to open the image editor.
  #
  # ### Mode
  #
  # Html
  #
  def image_for_image_editor
    get_images(1)
    @back = params[:back] if params[:back].present?
    render :layout => 'media_element_editor'
  end
  
  # ### Description
  #
  # Gets following blocks of images for the image editor
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * GalleriesController#initialize_page
  #
  def image_for_image_editor_new_block
    if @ok
      get_images(@page)
    else
      render :nothing => true
    end
  end
  
  # ### Description
  #
  # Gets the first block of documents for the lesson editor
  #
  # ### Mode
  #
  # Ajax
  #
  def document_for_lesson_editor
    get_documents(1)
  end
  
  # ### Description
  #
  # Gets following blocks of documents for the lesson editor
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * GalleriesController#initialize_page
  #
  def document_for_lesson_editor_new_block
    if @ok
      @word = params[:word].blank? ? nil : params[:word]
      get_documents(@page, @word)
    else
      render :nothing => true
    end
  end
  
  # ### Description
  #
  # Gets documents filtered by word
  #
  # ### Mode
  #
  # Ajax
  #
  def document_for_lesson_editor_filter
    @word = params[:word].blank? ? nil : params[:word]
    get_documents(@page, @word)
  end
  
  # ### Description
  #
  # Action that calls the uploader from inside Lesson Editor, and creates the new audio.
  #
  # ### Mode
  #
  # Html
  #
  def create_audio
    record = initialize_media_element_creation
    if record.valid?
      if record.sti_type == 'Audio'
        if record.save
          get_audios(1)
          Notification.send_to(
            current_user.id,
            I18n.t('notifications.audio.upload.started.title'),
            I18n.t('notifications.audio.upload.started.message', :item => record.title),
            ''
          )
        end
      else
        @errors = {:media => t('forms.error_captions.wrong_sti_type.audio').downcase}
      end
    else
      if record.errors.added? :media, :too_large
        return render :file => Rails.root.join('public/413.html'), :layout => false, :status => 413
      end
      @errors = convert_media_element_error_messages record.errors
      @errors[:media] = t('forms.error_captions.wrong_sti_type.audio').downcase if !@errors.has_key?(:media) && record.sti_type != 'Audio'
    end
    render :layout => false
  end
  
  # ### Description
  #
  # Action that calls the uploader from inside Lesson Editor, and creates the new image.
  #
  # ### Mode
  #
  # Html
  #
  def create_image
    record = initialize_media_element_creation
    if record.valid?
      if record.sti_type == 'Image'
        record.save
        get_images(1)
      else
        @errors = {:media => t('forms.error_captions.wrong_sti_type.image').downcase}
      end
    else
      if record.errors.added? :media, :too_large
        return render :file => Rails.root.join('public/413.html'), :layout => false, :status => 413
      end
      @errors = convert_media_element_error_messages record.errors
      @errors[:media] = t('forms.error_captions.wrong_sti_type.image').downcase if !@errors.has_key?(:media) && record.sti_type != 'Image'
    end
    render :layout => false
  end
  
  # ### Description
  #
  # Action that calls the uploader from inside Lesson Editor, and creates the new video.
  #
  # ### Mode
  #
  # Html
  #
  def create_video
    record = initialize_media_element_creation
    if record.valid?
      if record.sti_type == 'Video'
        if record.save
          get_videos(1)
          Notification.send_to(
            current_user.id,
            I18n.t('notifications.video.upload.started.title'),
            I18n.t('notifications.video.upload.started.message', :item => record.title),
            ''
          )
        end
      else
        @errors = {:media => t('forms.error_captions.wrong_sti_type.video').downcase}
      end
    else
      if record.errors.added? :media, :too_large
        return render :file => Rails.root.join('public/413.html'), :layout => false, :status => 413
      end
      @errors = convert_media_element_error_messages record.errors
      @errors[:media] = t('forms.error_captions.wrong_sti_type.video').downcase if !@errors.has_key?(:media) && record.sti_type != 'Video'
    end
    render :layout => false
  end
  
  # ### Description
  #
  # This action checks for errors without setting the media on the new element
  #
  # ### Mode
  #
  # Js
  #
  def create_fake_media_element
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
  # Action that calls the uploader from inside Lesson Editor, and creates the new document.
  #
  # ### Mode
  #
  # Html
  #
  def create_document
    record = Document.new :attachment => params[:media]
    record.title = params[:title_placeholder] != '0' ? '' : params[:title]
    record.description = params[:description_placeholder] != '0' ? '' : params[:description]
    record.user_id = current_user.id
    if !record.save
      if record.errors.added? :attachment, :too_large
        return render :file => Rails.root.join('public/413.html'), :layout => false, :status => 413
      end
      @errors = convert_document_error_messages record.errors
    else
      get_documents(1)
      @document_id = record.id
    end
    render :layout => false
  end
  
  # ### Description
  #
  # This action checks for errors without setting the attachment on the new document
  #
  # ### Mode
  #
  # Js
  #
  def create_fake_document
    record = Document.new
    record.title = params[:title_placeholder] != '0' ? '' : params[:title]
    record.description = params[:description_placeholder] != '0' ? '' : params[:description]
    record.user_id = current_user.id
    record.valid?
    @errors = convert_document_error_messages record.errors
    @errors[:media] = t('documents.upload_form.attachment_too_large').downcase
  end
  
  private
  
  # Common operations in media element initialization.
  def initialize_media_element_creation
    record = MediaElement.new :media => params[:media]
    record.title = params[:title_placeholder] != '0' ? '' : params[:title]
    record.description = params[:description_placeholder] != '0' ? '' : params[:description]
    record.tags = params[:tags_value]
    record.user_id = current_user.id
    record.save_tags = true
    record
  end
  
  # Initializes the parameter +page+ used in all the actions getting new blocks in the gallery
  def initialize_page
    @page = correct_integer?(params[:page]) ? params[:page].to_i : 0
    update_ok(@page > 0)
  end
  
  # Gets the audios, using User#own_media_elements with +filter+ = +audio+
  def get_audios(page)
    x = current_user.own_media_elements(page, AUDIOS_FOR_PAGE, Filters::AUDIO, true)
    @audios = x[:records]
    @tot_pages = x[:pages_amount]
  end
  
  # Gets the videos, using User#own_media_elements with +filter+ = +video+
  def get_videos(page)
    x = current_user.own_media_elements(page, VIDEOS_FOR_PAGE, Filters::VIDEO, true)
    @videos = x[:records]
    @tot_pages = x[:pages_amount]
  end
  
  # Gets the images, using User#own_media_elements with +filter+ = +image+
  def get_images(page)
    x = current_user.own_media_elements(page, IMAGES_FOR_PAGE, Filters::IMAGE, true)
    @images = x[:records]
    @tot_pages = x[:pages_amount]
  end
  
  # Gets the documents, using User#own_documents
  def get_documents(page, word = nil)
    x = current_user.own_documents(page, DOCUMENTS_FOR_PAGE, SearchOrders::CREATED_AT, word, true)
    @documents = x[:records]
    @tot_pages = x[:pages_amount]
  end
  
end

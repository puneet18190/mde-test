# ### Description
#
# Controller of elements in the administration section. See AdminController.
#
# ### Models used
#
# * MediaElement
# * Location
# * AdminSearchForm
#
class Admin::MediaElementsController < AdminController
  
  before_filter :initialize_media_element_with_owner_and_private, :only => :update
  layout 'admin'
  
  # ### Description
  #
  # Main page of elements in the admin. If params[:search] is present, it is used AdminSearchForm to perform the requested search.
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  #
  def index
    elements = AdminSearchForm.search_media_elements((params[:search] ? params[:search] : {:ordering => 0, :desc => 'true'}))
    @elements = elements.preload(:user, :taggings, {:taggings => :tag}).page(params[:page])
    @locations = [Location.roots.order(:name)]
    if params[:search]
      location = Location.get_from_chain_params params[:search]
      @locations = location.select_without_selected if location
    end
    @from_reporting = params[:from_reporting]
  end
  
  # ### Description
  #
  # It opens the page for multiple loading of elements
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  #
  def new
    @files = current_user.admin_quick_uploading_cache
  end
  
  # ### Description
  #
  # It opens the page for updating and sharing the private elements loaded by the administrator
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  #
  def edit
    @private_elements = MediaElement.order('created_at DESC').where(:user_id => current_user.id, :is_public => false, :converted => true).preload(:user, :taggings, {:taggings => :tag})
  end
  
  # ### Description
  #
  # Single action of a multiple loading of elements (with a multiple loading many of these actions are fired)
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  #
  def quick_upload
    if params.has_key? :from_ie
      @file = current_user.save_in_admin_quick_uploading_cache params[:media], params[:title], params[:description], params[:tags] if params.has_key? :media
      redirect_to '/admin/media_elements/new' 
    else
      @file = current_user.save_in_admin_quick_uploading_cache params[:media], params[:title], params[:description], params[:tags]
    end
  end
  
  # ### Description
  #
  # Deletes a temporary file in the multiple uploading section
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  #
  def quick_upload_delete
    @key = :"#{params[:key]}"
    @ok = current_user.remove_from_admin_quick_uploading_cache @key
  end
  
  # ### Description
  #
  # Submits one of the multiple upload temporary files and creates a new element
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  #
  def create
    @key = :"#{params[:key]}"
    @ok = true
    filename = File.basename(params[:media])
    if !filename.nil?
      me = MediaElement.new :media => File.open(Rails.root.join("public/admin/#{current_user.id}/#{filename}"))
      me.title = params[:title_placeholder].blank? ? params[:title] : ''
      me.description = params[:description_placeholder].blank? ? params[:description] : ''
      me.tags = params[:tags_placeholder].blank? ? params[:tags] : ''
      me.user_id = current_user.id
      me.save_tags = true
      @saved = me.save
      if !@saved
        fields = me.errors.messages.keys
        if fields.include? :sti_type
          fields << :media if !fields.include? :media
          fields.delete :sti_type
        end
        @error_fields = []
        fields.each do |f|
          @error_fields << f.to_s
        end
        @ok = false if @error_fields.empty?
      else
        if params.has_key? :publish
          me = MediaElement.find me.id
          me.is_public = true
          me.publication_date = Time.zone.now
          @ok = me.save
        end
        current_user.remove_from_admin_quick_uploading_cache(@key)
      end
    else
      @ok = false
    end
  end
  
  # ### Description
  #
  # Updates or publishes a private media element loaded by the administrator
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  # * ApplicationController#initialize_media_element_with_owner_and_private
  #
  def update
    if @ok
      @media_element.title = params[:title]
      @media_element.description = params[:description]
      @media_element.tags = params[:tags]
      @media_element.save_tags = true
      if params[:is_public]
        @media_element.is_public = true
        @media_element.publication_date = Time.zone.now
      end
      @error_fields = @media_element.errors.messages.keys if !@media_element.save
    end
  end
  
  # ### Description
  #
  # Destroys an element without the normal filters, from the administrator
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  #
  def destroy
    @element = MediaElement.find(params[:id])
    @element.destroyable_even_if_public = true
    @element.destroy
    redirect_to params[:back_url]
  end
  
  # ### Description
  #
  # Loads an element in the administrator (so the server is not charged too much)
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  #
  def load_media_element
    @element = MediaElement.find(params[:id])
  end
  
end

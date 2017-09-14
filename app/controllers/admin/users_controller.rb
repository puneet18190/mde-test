# ### Description
#
# Controller for users in the administration section (see AdminController).
#
# ### Models used
#
# * AdminSearchForm
# * Location
# * User
# * Lesson
# * MediaElement
#
class Admin::UsersController < AdminController
  
  layout 'admin'
  
  # ### Description
  #
  # Main page with the list of users. If params[:search] is present, it is used AdminSearchForm to perform the requested search.
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
    users = AdminSearchForm.search_users((params[:search] ? params[:search] : {:ordering => 0, :desc => 'true'}))
    @users = users.preload(:location, :school_level).page(params[:page])
    @locations = [Location.roots.order(:name)]
    if params[:search]
      location = Location.get_from_chain_params params[:search]
      @locations = location.select_without_selected if location
    end
  end
  
  # ### Description
  #
  # 'Show' action for a single user. It contains personal statistics.
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  #
  def show
    @user = User.find(params[:id])
    Statistics.user = @user
    @user_lessons        = Lesson.select('lessons.*, (SELECT COUNT (*) FROM likes WHERE likes.lesson_id = lessons.id) AS likes_count').where(:user_id => @user.id).preload(:subject, :user, :taggings, {:taggings => :tag}).order('updated_at DESC').limit(10)
    user_lessons_covers  = Slide.where(:lesson_id => @user_lessons.pluck(:id), :kind => 'cover').preload(:media_elements_slides, {:media_elements_slides => :media_element})
    @user_lessons_covers = {}
    user_lessons_covers.each do |cov|
      @user_lessons_covers[cov.lesson_id] = cov
    end
    @user_elements       = MediaElement.where(:user_id => @user.id).order('updated_at DESC').preload(:user, :taggings, {:taggings => :tag}).limit(10)
    @my_created_lessons  = Statistics.my_created_lessons
    @my_created_elements = Statistics.my_created_elements
    @my_copied_lessons   = Statistics.my_copied_lessons
    @my_liked_lessons    = Statistics.my_liked_lessons(3)
    @my_likes_count      = Statistics.my_likes_count
  end
  
  # ### Description
  #
  # Action to destroy a user and remove its contact from the database (see User#destroy_with_dependencies)
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  #
  def destroy
    @user = User.find(params[:id])
    @user.destroy_with_dependencies
  end
  
  # ### Description
  #
  # Used for autocomplete in the search forms all over the administration section
  #
  # ### Mode
  #
  # Json
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  #
  def get_full_names
    @users = User.get_full_names(params[:term])
    render :json => @users
  end
  
  # ### Description
  #
  # Used for location filling all over the administration section (to be distinguished by UsersController#find_locations, which is used in the rest of the application)
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  #
  def find_locations
    parent = Location.find_by_id params[:id]
    @locations = parent.nil? ? [] : parent.children.order(:name)
  end
  
  # ### Description
  #
  # To switch the status of a user form 'banned' to 'active' and viceversa: used only in the main list of users (Admin::UsersController#index)
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  #
  def set_status
    @user = User.find params[:id]
    @user.active = params[:active]
    @user.save
  end
  
  # ### Description
  #
  # Sets the field +active+ of User to +false+ (used only in Admin::UsersController#show)
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  #
  def ban
    @user = User.find params[:id]
    @user.active = false
    @user.save
    redirect_to admin_user_path(@user)
  end
  
  # ### Description
  #
  # Sets the field +active+ of User to +true+ (used only in Admin::UsersController#show)
  #
  # ### Mode
  #
  # Html
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  #
  def activate
    @user = User.find params[:id]
    @user.active = true
    @user.save
    redirect_to admin_user_path(@user)
  end
  
  # ### Description
  #
  # Sends again the email confirmation to an unconfirmed user.
  #
  # ### Mode
  #
  # Js
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  #
  def reconfirm
    @user = User.find params[:id]
    UserMailer.account_confirmation(@user).deliver
    @message = t('admin.users.actions.reconfirm_sent', :email => @user.email)
  end
  
end

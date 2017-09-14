# ### Description
#
# This class contains the list of search methods used in the administrator.
# Unlike the methods used in the application's search engine (see User#search_lessons, User#search_media_elements), these search methods are not optimized and indicized.
#
class AdminSearchForm
  
  # List of possible values for the parameter 'recency'
  RECENCIES = [1.day, 1.week, 1.month, 1.year]
  
  # Hash of possible orderings, one for each method.
  ORDERINGS = {
    :media_elements => [
      'media_elements.id %{ord}',
      'media_elements.title %{ord}',
      'media_elements.sti_type %{ord}',
      'users.surname %{ord}, users.name %{ord}',
      'media_elements.created_at %{ord}',
      'media_elements.updated_at %{ord}',
      'media_elements.is_public %{ord}'
    ],
    :lessons => [
      'lessons.id %{ord}',
      'lessons.title %{ord}',
      'subjects.description %{ord}',
      'users.surname %{ord}, users.name %{ord}',
      'lessons.created_at %{ord}',
      'lessons.updated_at %{ord}'
    ],
    :users => [
      'users.id %{ord}',
      'users.email %{ord}',
      'users.name %{ord}',
      'users.surname %{ord}',
      'school_levels.description %{ord}',
      'locations.name %{ord}',
      'locations.ancestry %{ord}',
      'users.created_at %{ord}'
    ],
    :tags => [
      'id %{ord}',
      'word %{ord}',
      'created_at %{ord}',
      'lessons_count %{ord}',
      'media_elements_count %{ord}'
    ],
    :documents => [
      'documents.id %{ord}',
      'documents.title %{ord}',
      'users.surname %{ord}, users.name %{ord}',
      'documents.created_at %{ord}',
      'documents.updated_at %{ord}'
    ],
    :purchases => [
      'id %{ord}',
      'name %{ord}',
      'responsible %{ord}',
      'email %{ord}',
      'ssn_code %{ord}',
      'vat_code %{ord}',
      'postal_code %{ord}',
      'city %{ord}',
      'country %{ord}',
      'accounts_number %{ord}',
      'release_date %{ord}',
      'start_date %{ord}',
      'expiration_date %{ord}'
    ]
  }
  
  # ### Description
  #
  # Search for documents: used in Admin::DocumentsController
  #
  # ### Args
  #
  # * *params*: url subparams, under the scope of the keyword 'search': the options are
  #   * +id+: if present the methods filters by id
  #   * +title+: if present the methods filters by title
  #   * +date_range_field+: if present, it specifies which date field is used to filter by date (+created_at+ or +updated_at+)
  #   * +from+: if the parameter +date_range_field+ is present, this parameter specifies the left border of the date range
  #   * +to+: if the parameter +date_range_field+ is present, this parameter specifies the right border of the date range
  #   * +user+: if present the methods filters by user name (the keyword is matched against +name+, +surname+ and +email+)
  #   * +location_id+: if present the methods filters by location of the user (see settings.yml for the possible names of this parameter)
  #   * +ordering+: if present the methods sorts the results: the content of this parameter is a code, used to extract the required ordering from the constant ORDERINGS
  #   * +desc+: for default the ordering is +ASC+, if this parameter is present it's turned to +DESC+
  #
  # ### Returns
  #
  # An array, not paginated yet, of records of type Document
  #
  def self.search_documents(params)
    resp = Document.select('documents.*, users.name AS users_name, users.surname AS users_surname')
    resp = resp.joins(:user)
    if params[:ordering].present?
      ord = ORDERINGS[:documents][params[:ordering].to_i]
      ord = ORDERINGS[:documents][0] if ord.nil?
      if params[:desc] == 'true'
        ord = ord.gsub('%{ord}', 'DESC')
      else
        ord = ord.gsub('%{ord}', 'ASC')
      end
      resp = resp.order(ord)
    end
    resp = resp.where(:documents => {:id => params[:id]}) if params[:id].present?
    resp = resp.where('title ILIKE ?', "%#{params[:title]}%") if params[:title].present?
    if params[:date_range_field].present? && params[:from].present? && params[:to].present?
      date_range = (Date.strptime(params[:from], '%d-%m-%Y').beginning_of_day)..(Date.strptime(params[:to], '%d-%m-%Y').end_of_day)
      resp = resp.where(:documents => {:"#{params[:date_range_field]}" => date_range})
    end
    resp = resp.where('users.name ILIKE ? OR users.surname ILIKE ? OR email ILIKE ?', "%#{params[:user]}%", "%#{params[:user]}%", "%#{params[:user]}%") if params[:user].present?
    location = Location.get_from_chain_params(params)
    if location
      if location.depth == SETTINGS['location_types'].length - 1
        resp = resp.where(:users => {:location_id => location.id})
      else
        resp = resp.joins(:user => :location)
        if location.ancestry.nil?
          resp = resp.where('ancestry LIKE ? OR ancestry = ?', "#{location.ancestry_with_me}%", location.id.to_s)
        else
          resp = resp.where('ancestry LIKE ?', "#{location.ancestry_with_me}%")
        end
      end
    end
    resp
  end
  
  # ### Description
  #
  # Search for purchases: used in Admin::PurchasesController
  #
  # ### Args
  #
  # * *params*: url subparams, under the scope of the keyword 'search': the options are
  #   * +id+: if present the methods filters by id
  #   * +ssn_code+: if present the methods filters by ssn_code with an like on both sides
  #   * +vat_code+: if present the methods filters by vat_code with an like on both sides
  #   * +name+: if present the methods filters by name with an like on both sides
  #   * +responsible+: if present the methods filters by responsible with an like on both sides
  #   * +email+: if present the methods filters by email with an like on both sides
  #
  # ### Returns
  #
  # An array, not paginated yet, of records of type Document
  #
  def self.search_purchases(params)
    resp = Purchase
    if params[:ordering].present?
      ord = ORDERINGS[:purchases][params[:ordering].to_i]
      ord = ORDERINGS[:purchases][0] if ord.nil?
      if params[:desc] == 'true'
        ord = ord.gsub('%{ord}', 'DESC')
      else
        ord = ord.gsub('%{ord}', 'ASC')
      end
      resp = resp.order(ord)
    end
    resp = resp.where(:id => params[:id]) if params[:id].present?
    resp = resp.where('ssn_code ILIKE ?', "%#{params[:ssn_code]}%") if params[:ssn_code].present?
    resp = resp.where('vat_code ILIKE ?', "%#{params[:vat_code]}%") if params[:vat_code].present?
    resp = resp.where('name ILIKE ?', "%#{params[:name]}%") if params[:name].present?
    resp = resp.where('responsible ILIKE ?', "%#{params[:responsible]}%") if params[:responsible].present?
    resp = resp.where('email ILIKE ?', "%#{params[:email]}%") if params[:email].present?
    resp
  end
  
  # ### Description
  #
  # Search for lessons: used in Admin::LessonsController
  #
  # ### Args
  #
  # * *params*: url subparams, under the scope of the keyword 'search': the options are
  #   * +id+: if present the methods filters by id
  #   * +title+: if present the methods filters by title
  #   * +subject_id+: if present the methods filters by subject
  #   * +date_range_field+: if present, it specifies which date field is used to filter by date (+created_at+ or +updated_at+)
  #   * +from+: if the parameter +date_range_field+ is present, this parameter specifies the left border of the date range
  #   * +to+: if the parameter +date_range_field+ is present, this parameter specifies the right border of the date range
  #   * +user+: if present the methods filters by user name (the keyword is matched against +name+, +surname+ and +email+)
  #   * +location_id+: if present the methods filters by location of the user (see settings.yml for the possible names of this parameter)
  #   * +ordering+: if present the methods sorts the results: the content of this parameter is a code, used to extract the required ordering from the constant ORDERINGS
  #   * +desc+: for default the ordering is +ASC+, if this parameter is present it's turned to +DESC+
  #
  # ### Returns
  #
  # An array, not paginated yet, of records of type Lesson
  #
  def self.search_lessons(params)
    resp = Lesson.select('lessons.*, (SELECT COUNT (*) FROM likes WHERE likes.lesson_id = lessons.id) AS likes_count')
    resp = resp.joins(:user)
    if params[:ordering].present?
      ord = ORDERINGS[:lessons][params[:ordering].to_i]
      if ord.nil? && params[:ordering].to_i == 6
        desc = params[:desc] == 'true' ? 'DESC' : 'ASC'
        resp = resp.order("likes_count #{desc}")
      else
        if params[:ordering].to_i == 2
          resp = resp.joins(:subject)
        else
          ord = ORDERINGS[:lessons][0] if ord.nil?
        end
        if params[:desc] == 'true'
          ord = ord.gsub('%{ord}', 'DESC')
        else
          ord = ord.gsub('%{ord}', 'ASC')
        end
        resp = resp.order(ord)
      end
    end
    resp = resp.where(:lessons => {:id => params[:id]}) if params[:id].present?
    resp = resp.where('title ILIKE ?', "%#{params[:title]}%") if params[:title].present?
    resp = resp.where(:subject_id => params[:subject_id]) if params[:subject_id].present?
    if params[:date_range_field].present? && params[:from].present? && params[:to].present?
      date_range = (Date.strptime(params[:from], '%d-%m-%Y').beginning_of_day)..(Date.strptime(params[:to], '%d-%m-%Y').end_of_day)
      resp = resp.where(:lessons => {:"#{params[:date_range_field]}" => date_range})
    end
    resp = resp.where('users.name ILIKE ? OR users.surname ILIKE ? OR email ILIKE ?', "%#{params[:user]}%", "%#{params[:user]}%", "%#{params[:user]}%") if params[:user].present?
    location = Location.get_from_chain_params(params)
    if location
      if location.depth == SETTINGS['location_types'].length - 1
        resp = resp.where(:users => {:location_id => location.id})
      else
        resp = resp.joins(:user => :location)
        if location.ancestry.nil?
          resp = resp.where('ancestry LIKE ? OR ancestry = ?', "#{location.ancestry_with_me}%", location.id.to_s)
        else
          resp = resp.where('ancestry LIKE ?', "#{location.ancestry_with_me}%")
        end
      end
    end
    resp
  end
  
  # ### Description
  #
  # Search for media elements: used in Admin::MediaElementsController
  #
  # ### Args
  #
  # * *params*: url subparams, under the scope of the keyword 'search': the options are
  #   * +id+: if present the methods filters by id
  #   * +title+: if present the methods filters by title
  #   * +sti_type+: if present the methods filters by media type (audio, image or video)
  #   * +date_range_field+: if present, it specifies which date field is used to filter by date (+created_at+ or +updated_at+)
  #   * +from+: if the parameter +date_range_field+ is present, this parameter specifies the left border of the date range
  #   * +to+: if the parameter +date_range_field+ is present, this parameter specifies the right border of the date range
  #   * +user+: if present the methods filters by user name (the keyword is matched against +name+, +surname+ and +email+)
  #   * +location_id+: if present the methods filters by location of the user (see settings.yml for the possible names of this parameter)
  #   * +ordering+: if present the methods sorts the results: the content of this parameter is a code, used to extract the required ordering from the constant ORDERINGS
  #   * +desc+: for default the ordering is +ASC+, if this parameter is present it's turned to +DESC+
  #
  # ### Returns
  #
  # An array, not paginated yet, of records of type MediaElement
  #
  def self.search_media_elements(params)
    resp = MediaElement.where(:converted => true)
    if params[:ordering].present?
      ord = ORDERINGS[:media_elements][params[:ordering].to_i]
      ord = ORDERINGS[:media_elements][0] if ord.nil?
      if params[:desc] == 'true'
        ord = ord.gsub('%{ord}', 'DESC')
      else
        ord = ord.gsub('%{ord}', 'ASC')
      end
      resp = resp.order(ord)
    end
    resp = resp.where(:media_elements => {:id => params[:id]}) if params[:id].present?
    resp = resp.where('title ILIKE ?', "%#{params[:title]}%") if params[:title].present?
    resp = resp.where(:sti_type => params[:sti_type]) if params[:sti_type].present?
    if params[:date_range_field].present? && params[:from].present? && params[:to].present?
      date_range = (Date.strptime(params[:from], '%d-%m-%Y').beginning_of_day)..(Date.strptime(params[:to], '%d-%m-%Y').end_of_day)
      resp = resp.where(:media_elements => {:"#{params[:date_range_field]}" => date_range})
    end
    with_joins = params[:user].present?
    SETTINGS['location_types'].map{|type| type.downcase}.each do |type|
      with_joins = true if params[type].present? && params[type] != '0'
    end
    if with_joins
      resp = resp.joins(:user)
      resp = resp.where('users.name ILIKE ? OR users.surname ILIKE ? OR email ILIKE ?', "%#{params[:user]}%", "%#{params[:user]}%", "%#{params[:user]}%") if params[:user].present?
      location = Location.get_from_chain_params(params)
      if location
        if location.depth == SETTINGS['location_types'].length - 1
          resp = resp.where(:users => {:location_id => location.id})
        else
          resp = resp.joins(:user => :location)
          if location.ancestry.nil?
            resp = resp.where('ancestry LIKE ? OR ancestry = ?', "#{location.ancestry_with_me}%", location.id.to_s)
          else
            resp = resp.where('ancestry LIKE ?', "#{location.ancestry_with_me}%")
          end
        end
      end
    end
    resp
  end
  
  # ### Description
  #
  # Search for users: used in Admin::UsersController
  #
  # ### Args
  #
  # * *params*: url subparams, under the scope of the keyword 'search': the options are
  #   * +id+: if present the methods filters by id
  #   * +user+: if present the keyword is matched against +name+, +surname+ and +email+ and the result is filtered
  #   * +school_level_id+: if present the methods filters by school_level
  #   * +date_range_field+: if present, it specifies which date field is used to filter by date (+created_at+ or +updated_at+)
  #   * +from+: if the parameter +date_range_field+ is present, this parameter specifies the left border of the date range
  #   * +to+: if the parameter +date_range_field+ is present, this parameter specifies the right border of the date range
  #   * +subject_id+: if present, the method filters by subject_id, using the relation UsersSubject
  #   * +location_id+: if present the methods filters by location of the user (see settings.yml for the possible names of this parameter)
  #   * +ordering+: if present the methods sorts the results: the content of this parameter is a code, used to extract the required ordering from the constant ORDERINGS
  #   * +desc+: for default the ordering is +ASC+, if this parameter is present it's turned to +DESC+
  #
  # ### Returns
  #
  # An array, not paginated yet, of records of type User.
  #
  def self.search_users(params)
    resp = User
    if params[:ordering].present?
      ord = ORDERINGS[:users][params[:ordering].to_i]
      if params[:ordering].to_i == 4
        resp = resp.joins(:school_level)
      elsif [5, 6].include? params[:ordering].to_i
        resp = resp.joins(:location)
      else
        ord = ORDERINGS[:users][0] if ord.nil?
      end
      if params[:desc] == 'true'
        ord = ord.gsub('%{ord}', 'DESC')
      else
        ord = ord.gsub('%{ord}', 'ASC')
      end
      resp = resp.order(ord)
    end
    resp = resp.where(:users => {:id => params[:id]}) if params[:id].present?
    resp = resp.where(:users => {:purchase_id => params[:purchase_id]}) if params[:purchase_id].present?
    resp = resp.where('users.name ILIKE ? OR surname ILIKE ? OR email ILIKE ?', "%#{params[:user]}%" , "%#{params[:user]}%", "%#{params[:user]}%") if params[:user].present?
    resp = resp.where(:school_level_id => params[:school_level_id]) if params[:school_level_id].present?
    if params[:date_range_field].present? && params[:from].present? && params[:to].present?
      date_range = (Date.strptime(params[:from], '%d-%m-%Y').beginning_of_day)..(Date.strptime(params[:to], '%d-%m-%Y').end_of_day)
      resp = resp.where(:users => {:"#{params[:date_range_field]}" => date_range})
    end
    if params[:subject_id].present?
      resp = resp.joins(:users_subjects).group('users.id')
      resp = resp.where(:users_subjects => {:subject_id => params[:subject_id]})
    end
    with_locations = false
    SETTINGS['location_types'].map{|type| type.downcase}.each do |type|
      with_locations = true if params[type].present? && params[type] != '0'
    end
    if with_locations
      location = Location.get_from_chain_params(params)
      if location
        if location.depth == SETTINGS['location_types'].length - 1
          resp = resp.where(:users => {:location_id => location.id})
        else
          resp = resp.joins(:location)
          if location.ancestry.nil?
            resp = resp.where('ancestry LIKE ? OR ancestry = ?', "#{location.ancestry_with_me}%", location.id.to_s)
          else
            resp = resp.where('ancestry LIKE ?', "#{location.ancestry_with_me}%")
          end
        end
      end
    end
    resp
  end
  
  # ### Description
  #
  # Search for tags: used in Admin::SettingsController
  #
  # ### Args
  #
  # * *params*: url subparams, under the scope of the keyword 'search': the options are
  #   * +id+: if present the methods filters by id
  #   * +recency+: if present, it filters by +created_at+ greater than one year ago, one month ago, a week ago, or a day ago
  #   * +word+: it present, it matches the keyword with the tag content, and filters the result
  #   * +ordering+: if present the methods sorts the results: the content of this parameter is a code, used to extract the required ordering from the constant ORDERINGS
  #   * +desc+: for default the ordering is +ASC+, if this parameter is present it's turned to +DESC+
  #
  # ### Returns
  #
  # An array, not paginated yet, of objects of type Tag
  #
  def self.search_tags(params)
    resp = Tag.select("id, word, created_at, (SELECT COUNT (*) FROM taggings WHERE taggings.tag_id = tags.id AND taggings.taggable_type = 'MediaElement') AS media_elements_count, (SELECT COUNT (*) FROM taggings WHERE taggings.tag_id = tags.id AND taggings.taggable_type = 'Lesson') AS lessons_count")
    if params[:ordering].present?
      ord = ORDERINGS[:tags][params[:ordering].to_i]
      ord = ORDERINGS[:tags][0] if ord.nil?
      if params[:desc] == 'true'
        ord = ord.gsub('%{ord}', 'DESC')
      else
        ord = ord.gsub('%{ord}', 'ASC')
      end
      resp = resp.order(ord)
    end
    resp = resp.where(:id => params[:id]) if params[:id].present?
    resp = resp.where('word ILIKE ?', "%#{params[:word]}%") if params[:word].present?
    resp = resp.where('created_at >= ?', RECENCIES[params[:recency].to_i - 1].ago) if params[:recency].present?
    resp
  end
  
  # ### Description
  #
  # Search for users who are going to receive a massive notification: this method is used to update asynchronously the form to send a massive notification from the administrator. Used in Admin::MessagesController
  #
  # ### Args
  #
  # * *params*: url subparams, under the scope of the keyword 'search': the options are
  #   * +id+: if present the methods filters by id
  #   * +user+: if present the keyword is matched against +name+, +surname+ and +email+ and the result is filtered
  #   * +school_level_id+: if present the methods filters by school_level
  #   * +recency+: if present, it filters by +created_at+ greater than one year ago, one month ago, a week ago, or a day ago
  #   * +subject_id+: if present, the method filters by subject_id, using the relation UsersSubject
  #   * +location_id+: if present the methods filters by location of the user (see settings.yml for the possible names of this parameter)
  #   * +user_ids+: list of users added manually to the list of recipients
  # * *count_only*: if set to +true+, the method returns only the number of users; if not otherwise specified, it's set to +false+
  #
  # ### Returns
  #
  # Depending on the value of +count_only+, either the number of records found, or a not paginated array of records of kind User
  #
  def self.search_notifications_users(params, count_only=false)
    resp = User.scoped
    resp = resp.where(:school_level_id => params[:school_level_id]) if params[:school_level_id].present?
    resp = resp.where('users.created_at >= ?', params[:recency]) if params[:recency].present?
    with_locations = false
    SETTINGS['location_types'].map{|type| type.downcase}.each do |type|
      with_locations = true if params[type].present? && params[type] != '0'
    end
    if with_locations
      location = Location.get_from_chain_params(params)
      if location
        if location.depth == SETTINGS['location_types'].length - 1
          resp = resp.where(:users => {:location_id => location.id})
        else
          if location.ancestry.nil?
            resp = resp.where('ancestry LIKE ? OR ancestry = ?', "#{location.ancestry_with_me}%", location.id.to_s)
          else
            resp = resp.where('ancestry LIKE ?', "#{location.ancestry_with_me}%")
          end
        end
      end
    end
    if params[:subject_id].present?
      resp = resp.where(:users_subjects => {:subject_id => params[:subject_id]})
    end
    if params[:users_ids].present?
      resp = User.where([resp.wheres.map(&:to_sql).join(' AND '), "users.id IN (#{params[:users_ids]})"].select{ |s| s.present? }.join(' OR ') )
    end
    if location
      resp = resp.joins(:location)
    end
    if resp.wheres.count == 0 && params[:users_ids].blank?
      empty = true
    end
    if params[:subject_id].present?
      resp = resp.joins(:users_subjects).group('users.id')
      count_resp = resp.count.length
    else
      count_resp = resp.count
    end
    if count_only
      if empty
        return 0
      else
        return count_resp
      end
    else
      if empty
        return []
      else
        return resp
      end
    end
  end
  
end

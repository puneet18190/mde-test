# Global helpers
module ApplicationHelper
  
  def contact_us_link
    mail_to SETTINGS['application']['contact_us_email'], t('prelogin.contact_us.menu_link')
  end
  
  # Gets the color of description popup into the document gallery
  def documents_type_color(document)
    Document::COLORS_BY_TYPE[document.type]
  end
  
  # Extracts the time from seconds.
  def seconds_to_time(seconds)
    Time.at(seconds).utc.strftime(seconds >= 3600 ? '%T' : '%M:%S')
  end
  
  # Gets the html class to scope css (controller).
  def controller_html_class
    "#{h controller_path}-controller"
  end
  
  # Gets the html class to scope css (action).
  def action_html_class
    "#{h action_name}-action"
  end
  
  # Manipulates the url, adding or removing parameters.
  def manipulate_url(options = {})
    params_to_remove = options[:remove_query_param]
    page             = options[:page]
    l_d_exp          = options[:l_d_exp]
    me_d_exp         = options[:me_d_exp]
    escape           = options[:escape]
    path             = options[:path] || request.path
    query_params = request.query_parameters.deep_dup
    if params_to_remove && query_params.present?
      params_to_remove.each do |param|
        query_params.delete(param.to_s)
      end
    end
    query_params[:page] = page if page
    query_params[:lessons_expanded] = l_d_exp if l_d_exp
    query_params[:media_elements_expanded] = me_d_exp if me_d_exp
    query_string = get_recursive_array_from_params(query_params).join('&')
    return path if query_string.blank?
    url = "#{path}?#{query_string}"
    url = URI.escape(url)
    escape ? CGI.escape(url) : url
  end
  
  # Method to help debugging views.
  if Rails.env.production?
    def jsd(object)
    end
  else
    def jsd(object)
      javascript_tag "console.log(#{object.inspect.to_json})"
    end
  end
  
  # Renders a two digits number even in the case the number is only one-digit.
  def two_digits_number(x)
    x < 10 ? "0#{x}" : x.to_s
  end
  
  # It stands for "interpolation escape"
  def ie(x)
    strip_tags(x).html_safe
  end
  
  private
  
  # Submethod of #manipulate_url, that takes into consideration nested url parameters.
  def get_recursive_array_from_params(params)
    return params if !params.kind_of?(Hash)
    resp = []
    params.each do |k, v|
      rec_ar = get_recursive_array_from_params(v)
      if rec_ar.kind_of?(Array)
        rec_ar.each do |r|
          if (r =~ /\]/).nil?
            resp << "#{k}[#{r.gsub('=', ']=')}"
          else
            temp_string = r[(r =~ /\[/) + 1, r.length]
            resp << "#{k}[#{r[0, (r =~ /\[/)]}][#{temp_string}"
          end
        end
      else
        resp << "#{k}=#{rec_ar}"
      end
    end
    resp
  end
  
  # Method to create the title of the html tab.
  def title_tag(slides = nil)
    controller, desy = controller_path, SETTINGS['application_name']
    return t('captions.titles.admin', :desy => desy) if controller.start_with? 'admin/'
    case controller
    when 'documents'
      t('captions.titles.documents', :desy => desy)
    when 'lessons', 'lesson_editor'
      t('captions.titles.lessons', :desy => desy)
    when 'audio_editor', 'image_editor', 'video_editor', 'media_elements'
      t('captions.titles.media_elements', :desy => desy)
    when 'users'
      t('captions.titles.profile', :desy => desy)
    when 'virtual_classroom'
      t('captions.titles.virtual_classroom', :desy => desy)
    when 'lesson_viewer', 'lesson_export'
      case action_name
      when 'index', 'archive'
        t('captions.titles.single_lesson', :desy => desy, :lesson => slides.first.lesson.title)
      else
        t('captions.titles.virtual_classroom', :desy => desy)
      end
    else
      t('captions.titles.default', :desy => desy)
    end
  end
  
  # The parameter +path+ must be an absolute path.
  def full_url(path)
    uri = URI.parse path
    uri.scheme, uri.host, uri.port = request.scheme, request.host, (request.port == 80 ? nil : request.port)
    uri.to_s
  end
  
  # Url by url type.
  def url_by_url_type(url, url_type)
    UrlTypes.url_by_url_type url ,url_type
  end
  
end

require 'pathname'

module UrlTypes

  EXPORT     = :export
  FULL_URL   = :full_url
  SCORM      = :scorm
  SCORM_HTML = :scorm_html
  
  module InstanceMethods

    private

    def url_by_url_type(url, url_type)
      case url_type

      when EXPORT
        Pathname(url).relative_path_from(Pathname('/')).to_s
      when FULL_URL
        URI::HTTP.build( SETTINGS['application']['default_url_options'].merge(path: url) ).to_s
      when SCORM
        File.join 'html', url
      when SCORM_HTML
        Pathname(url).relative_path_from(Pathname('/')).to_s
      else
        url
      end
    end

  end

  def self.included(receiver)
    receiver.send :include, InstanceMethods
  end
  
  extend InstanceMethods
  singleton_class.send :public, :url_by_url_type
  
end

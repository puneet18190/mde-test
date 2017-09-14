# Specific mailer for administration
class MaintainerNotificationsMailer < ActionMailer::Base
  
  layout 'shared/mailer'
  
  default :from => SETTINGS['application']['email'], :to => SETTINGS['application']['maintainer']['emails']
  
  # It sends an email if the media elements hard disk is getting full
  def media_elements_folder_size_alert(current_media_elements_folder_size, maximum_media_elements_folder_size)
    @current_media_elements_folder_size_in_gigabytes = current_media_elements_folder_size.to_f / 1024**3
    @maximum_media_elements_folder_size_in_gigabytes = maximum_media_elements_folder_size.to_f / 1024**3
    mail subject: "#{SETTINGS['application_name']} - media elements folder size is reaching the maximum size allowed"
  end
  
end

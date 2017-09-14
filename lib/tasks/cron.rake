namespace :cron do

  desc "Send a notification to the maintainer when the media elements folder uses the 80% of the maximum space required"
  task :media_elements_folder_size_alert => :environment do
    current_media_elements_folder_size = Media::Uploader.media_elements_folder_size
    if current_media_elements_folder_size >= Media::Uploader::MAXIMUM_MEDIA_ELEMENTS_FOLDER_SIZE.to_f / 100 * 80
      MaintainerNotificationsMailer.media_elements_folder_size_alert(current_media_elements_folder_size, Media::Uploader::MAXIMUM_MEDIA_ELEMENTS_FOLDER_SIZE).deliver
    end
  end

end
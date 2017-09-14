namespace :media do
  namespace :clean do
    desc 'clean audios folder'
    task :audios_folder => :environment do
      Media::Audio::Uploader.remove_folder!
    end

    desc 'clean videos folder'
    task :videos_folder => :environment do
      Media::Video::Uploader.remove_folder!
    end
    
    desc 'clean images folder'
    task :images_folder => :environment do
      ImageUploader.remove_folder!
    end

    desc 'clean audio conversions folder'
    task :audio_conversions_folder => :environment do
      Media::Audio::Editing::Conversion.remove_folder!
    end

    desc 'clean video conversions folder'
    task :video_conversions_folder => :environment do
      Media::Video::Editing::Conversion.remove_folder!
    end

    desc 'clean logs folder'
    task :logs_folder => :environment do
      Media::Logging.remove_folder!
    end
  end
  desc 'clean all folders'
  task :clean => %w( media:clean:audios_folder media:clean:videos_folder media:clean:images_folder media:clean:audio_conversions_folder media:clean:video_conversions_folder media:clean:logs_folder )
end
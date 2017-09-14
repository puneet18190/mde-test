# clear the doc:app task et al so we can rewrite them
Rake::Task["db:reset"].clear
Rake::Task["db:setup"].clear

namespace :db do

  desc "Load structure and seed"
  task :load_structure_and_seed => %w( db:structure:load db:seed )

  desc "Performs an ANALYZE"
  task :analyze => :environment do
    ActiveRecord::Base.connection.execute 'ANALYZE'
  end

  # Warning: the config/pepper file must be the same of the one used when passwords are dumped; otherwise
  # users authentication will not work
  # FIXME BROKEN!!! should be updated in order to add the duration columns to media_elements.csv
  desc 'dumps the current database to CSV files for seeding usage'
  task :csv_dump => :environment do
    models_with_columns = {
      Bookmark           => %w( id user_id bookmarkable_id bookmarkable_type ),
      Lesson             => %w( id user_id school_level_id subject_id title description is_public parent_id copied_not_modified token notified ),
      Like               => %w( id lesson_id user_id ),
      Location           => %w( id name sti_type ancestry ),
      MediaElement       => %w( id user_id title description sti_type is_public publication_date ),
      MediaElementsSlide => %w( id media_element_id slide_id position caption alignment ),
      SchoolLevel        => %w( id description ),
      Slide              => %w( id lesson_id title text position kind ),
      Subject            => %w( id description ),
      Tag                => %w( id word ),
      Tagging            => %w( tag_id taggable_id taggable_type ),
      User               => %w( id email name surname school_level_id encrypted_password confirmed location_id active ),
      UsersSubject       => %w( user_id subject_id )
    }
    output_folder = Rails.root.join("db/seeds/environments/#{Rails.env}/csv")

    Dir.mktmpdir do |dir|
      models_with_columns.each do |model, columns|
        FileUtils.chmod 0777, dir
        csv_path = File.join dir, "#{model.table_name}.csv"
        model.connection.execute "COPY ( SELECT #{columns.map{ |c| model.connection.quote_column_name(c) }.join(', ')} 
                                         FROM #{model.quoted_table_name} ORDER BY id
                                       ) TO #{model.quote_value(csv_path.to_s)}
                                       WITH (FORMAT csv, HEADER true)"
      end
      FileUtils.mkdir_p output_folder
      FileUtils.rm_rf output_folder
      FileUtils.cp_r dir, output_folder
    end
  end

  desc "Create the database, load the schema, and initialize with the seed data (use db:reset to also drop the db first)"
  task :setup => %w( db:create db:structure:load db:seed db:analyze )
  
  desc "Recreate the database, load the schema, and initialize with the seed data"
  task :reset => %w( db:drop db:setup )

  desc "Rebuild database and schemas after a structural change, updating schema.rb, regardless of the configuration"
  task :rebuild => %w( db:drop db:create db:migrate db:seed db:analyze tmp:clear db:test:prepare db:structure:dump db:schema:dump )

  desc "empties all notifications"
  task :empty_notifications => :environment do
    Notification.all.each do |r|
      r.destroy
    end
  end
  
  desc "empties your lessons"
  task :empty_dashboard_lessons => :environment do
    Lesson.all.each do |r|
      r.destroy
    end
    Bookmark.where(:bookmarkable_type => 'Lesson', :user_id => 1).each do |r|
      r.destroy
    end
  end
  
  desc "empties your lessons"
  task :empty_lessons => :environment do
    Lesson.where(:user_id => 1).each do |r|
      r.destroy
    end
    Bookmark.where(:bookmarkable_type => 'Lesson', :user_id => 1).each do |r|
      r.destroy
    end
  end
  
  desc "empties dashboard media elements"
  task :empty_dashboard_media_elements => :environment do
    admin = User.admin
    MediaElement.where(:is_public => true).each do |r|
      admin.bookmark 'MediaElement', r.id
    end
  end
  
  desc "empties your media elements"
  task :empty_media_elements => :environment do
    MediaElement.where(:user_id => 1).each do |r|
      r.destroy
    end
    Bookmark.where(:bookmarkable_type => 'MediaElement', :user_id => 1).each do |r|
      r.destroy
    end
  end
  
  desc "Rebuild notifications without re-initializing the database"
  task :notifications => :environment do
    Notification.delete_all
    an_user_id = User.admin.id
    # 1 - English
    NotificationsTest.try_all(:en, an_user_id)
    # 2 - Italian
    NotificationsTest.try_all(:it, an_user_id)
    # 3 - Chinese
    NotificationsTest.try_all(:cn, an_user_id)
    # 4 - Try time differences
    time_now = Time.zone.now
    coefficients = [360, 3600, 8640, 86400, 262980, 2629800, 10155760, 31957700, 315577000]
    summing = false
    Notification.order('created_at ASC').limit(9).each_with_index do |n, i|
      Notification.where(:id => n.id).update_all(:created_at => time_now - coefficients[i])
    end
  end
  
end

namespace :exports do
  
  namespace :lessons do
        
    namespace :archives do
      
      desc "Remove lesson archives"
      task :clean => :environment do
        require 'export'
        Export::Lesson::Archive.remove_folder!
      end
      
      namespace :assets do
        
        desc "Remove compiled lesson exporting assets"
        task :clean => :environment do
          require 'export/lesson/archive/assets'
          Export::Lesson::Archive::Assets.remove_folder!
        end
        
        desc "Compile lesson exporting assets"
        task :compile => :environment do
          require 'export/lesson/archive/assets'
          Export::Lesson::Archive::Assets.compile
        end
        
        desc "Clean and compile lesson exporting assets"
        task :recompile => [:clean, :compile]
      end
      
    end
    
    namespace :ebooks do
      
      desc "Remove lesson ebooks"
      task :clean => :environment do
        require 'export'
        Export::Lesson::Ebook.remove_folder!
      end
      
      namespace :assets do
        
        desc "Remove compiled lesson exporting assets"
        task :clean => :environment do
          require 'export/lesson/ebook/assets'
          Export::Lesson::Ebook::Assets.remove_folder!
        end
        
        desc "Compile lesson exporting assets"
        task :compile => :environment do
          require 'export/lesson/ebook/assets'
          Export::Lesson::Ebook::Assets.compile
        end
        
        desc "Clean and compile lesson exporting assets for ebooks"
        task :recompile => [:clean, :compile]
        
      end
      
    end
    
    namespace :scorms do
      
      desc "Remove lesson scorms"
      task :clean => :environment do
        require 'export'
        Export::Lesson::Scorm.remove_folder!
      end
      
      namespace :assets do
        
        desc "Remove compiled lesson exporting assets for scorm"
        task :clean => :environment do
          require 'export/lesson/scorm/assets'
          Export::Lesson::Scorm::Assets.remove_folder!
        end
        
        desc "Compile lesson exporting assets for scorm"
        task :compile => :environment do
          require 'export/lesson/scorm/assets'
          Export::Lesson::Scorm::Assets.compile
        end
        
        desc "Clean and compile lesson exporting assets for scorm"
        task :recompile => [:clean, :compile]
        
      end
      
    end

    desc "Recompiles assets and remove the exported files"
    task :reset => %w( archives:assets:recompile ebooks:assets:recompile scorms:assets:recompile
                       archives:clean ebooks:clean scorms:clean )
    
  end
  
end

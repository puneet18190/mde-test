require 'fileutils'
require 'pathname'
require 'zlib'
require 'zip'
require 'env_relative_path'
require 'export'
require 'export/lesson'
require 'export/lesson/shared'

module Export
  
  module Lesson
    
    # Export scorms
    class Scorm
      require 'export/lesson/scorm/view'
      
      include EnvRelativePath
      include Shared
      
      # Folder where the scorm packages are exported
      OUTPUT_FOLDER                   = env_relative_pathname Rails.public_pathname, 'lessons', 'exports', 'scorms'
      
      # Folder from which the system extracts assets and templates
      INPUT_FOLDER                    = Lesson::FOLDER.join 'scorms'
      # Folder from which the system extracts precompiled assets
      INPUT_ASSETS_FOLDER             = INPUT_FOLDER.join 'assets'
      # Folder from which the system extracts templates
      INPUT_VIEWS_FOLDER              = View::FOLDER
      # Folder from which the system extracts static files to be copied in the scorm package
      INPUT_VIEWS_STATIC_FILES_FOLDER = INPUT_VIEWS_FOLDER.join 'static'
      
      # Root folder inside the scorm package
      FILE_ROOT_FOLDER                = Pathname '.'
      # Folder in the scorm package containing the html files
      FILE_HTML_FOLDER                = FILE_ROOT_FOLDER.join 'html'
      # Manifest in the scorm folder
      FILE_MANIFEST                   = FILE_ROOT_FOLDER.join 'imsmanifest.xml'
      # Assets in the scorm folder
      FILE_ASSETS_FOLDER              = FILE_HTML_FOLDER.join 'assets'
      # Math images in the scorm folder
      FILE_MATH_IMAGES_FOLDER         = FILE_HTML_FOLDER.join 'math_images'
      
      # Compression method
      COMPRESSION_METHOD              = Zip::Entry::STORED
      
      # Removes the folder containing extracted scorms
      def self.remove_folder!
        FileUtils.rm_rf OUTPUT_FOLDER
      end
      
      attr_reader :lesson, :rendered_slides, :output_folder, :filename, :output_path
      
      # Initializer
      def initialize(lesson, rendered_slides)
        @lesson, @rendered_slides  = lesson, rendered_slides
        parameterized_title        = lesson.title.parameterize
        filename_without_extension = lesson.id.to_s.tap{ |s| s << "_#{parameterized_title}" if parameterized_title.present? } << '.scorm'
        @output_folder             = OUTPUT_FOLDER.join lesson.id.to_s, lesson.updated_at.utc.strftime(WRITE_TIME_FORMAT)
        @filename                  = "#{filename_without_extension}.zip"
        @output_path               = output_folder.join filename
      end
      
      # Extracts the url of the new scorm
      def url
        find_or_create
        "/#{output_path.relative_path_from Rails.public_pathname}"
      end
      
      # If there is already an exported scorm for the latest version of this lesson, it retrieves it, otherwise it is created a new one
      def find_or_create
        return if output_path.exist?
        raise "Assets are not compiled. Please create them using rake exports:lessons:scorms:assets:compile" unless assets_compiled?
        remove_old_files if output_folder.exist?
        output_folder.mkpath
        create
      end
      
      private
      
      # Returns true or false, checking if the assets are compiled or not
      def assets_compiled?
        INPUT_ASSETS_FOLDER.exist? && INPUT_ASSETS_FOLDER.entries.present?
      end
      
      # Asset files
      def assets_files
        Pathname.glob INPUT_ASSETS_FOLDER.join('**', '*')
      end
      
      # Creates the scorm package
      def create
        Zip::File.open(output_path, Zip::File::CREATE) do |file|
          add_string_entry file, View.instance.render({template: 'imsmanifest.xml.erb', locals: {lesson: lesson}}), FILE_MANIFEST
          Pathname.glob(INPUT_VIEWS_STATIC_FILES_FOLDER.join('*')).each do |path|
            add_path_entry file, path, FILE_ROOT_FOLDER.join(path.basename)
          end
          rendered_slides.each do |slide_id, rendered_slide|
            add_string_entry file, rendered_slide, FILE_HTML_FOLDER.join("slide#{slide_id}.html")
          end
          assets_files.each do |path|
            add_path_entry file, path, FILE_ASSETS_FOLDER.join(path.relative_path_from INPUT_ASSETS_FOLDER)
          end
          media_elements_files(exclude_versions: [ :thumb, :cover ]).each do |path|
            add_path_entry file, path, FILE_HTML_FOLDER.join(path.relative_path_from MEDIA_ELEMENTS_UPFOLDER)
          end
          documents_files.each do |path|
            add_path_entry file, path, FILE_HTML_FOLDER.join(path.relative_path_from DOCUMENTS_UPFOLDER)
          end
          math_images.each do |path|
            add_path_entry file, path, FILE_MATH_IMAGES_FOLDER.join(path.basename)
          end
        end
        output_path.chmod 0644
      rescue
        output_path.unlink if output_path.exist?
        raise
      end
      
    end
    
  end
  
end

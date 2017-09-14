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
    class Archive

      include EnvRelativePath
      include Shared

      OUTPUT_FOLDER = env_relative_pathname Rails.public_pathname, 'lessons', 'exports', 'archives'
      
      INPUT_ASSETS_FOLDER     = Lesson::FOLDER.join 'archives', 'assets'
      FILE_ASSETS_FOLDER_NAME = 'assets'

      # STORED or DEFLATED
      COMPRESSION_METHOD = Zip::Entry::STORED

      FILE_INDEX_FILENAME = 'index.html'

      def self.remove_folder!
        FileUtils.rm_rf OUTPUT_FOLDER
      end

      attr_reader :lesson, :index_page, 
                  :filename_without_extension, :output_folder, :filename, :file_root_folder, :output_path, :file_assets_folder, :file_math_images_folder

      # index_page: String
      def initialize(lesson, index_page)
        @lesson, @index_page = lesson, index_page

        parameterized_title = lesson.title.parameterize
        time                = lesson.updated_at.utc.strftime(WRITE_TIME_FORMAT)

        @filename_without_extension = lesson.id.to_s.tap{ |s| s << "_#{parameterized_title}" if parameterized_title.present? }
        @output_folder              = OUTPUT_FOLDER.join lesson.id.to_s, time
        @filename                   = "#{filename_without_extension}.zip"
        @output_path                = output_folder.join filename
        @file_root_folder           = Pathname filename_without_extension
        @file_assets_folder         = file_root_folder.join FILE_ASSETS_FOLDER_NAME
        @file_math_images_folder    = file_root_folder.join FILE_MATH_IMAGES_FOLDER_NAME
      end

      def url
        find_or_create

        "/#{output_path.relative_path_from Rails.public_pathname}"
      end

      def find_or_create
        return if output_path.exist?
        
        # raises if export assets are not compiled
        raise "Assets are not compiled. Please create them using rake exports:lessons:archives:assets:compile" unless assets_compiled?

        remove_old_files if output_folder.exist?
        output_folder.mkpath
        create

        self
      end

      private

      def assets_compiled?
        INPUT_ASSETS_FOLDER.exist? && INPUT_ASSETS_FOLDER.entries.present?
      end

      def assets_files
        Pathname.glob INPUT_ASSETS_FOLDER.join('**', '*')
      end

      def create
        Zip::File.open(output_path, Zip::File::CREATE) do |archive|
          add_string_entry archive, index_page, file_root_folder.join(FILE_INDEX_FILENAME)

          assets_files.each do |path|
            add_path_entry archive, path, file_assets_folder.join(path.relative_path_from INPUT_ASSETS_FOLDER)
          end

          media_elements_files(exclude_versions: [ :thumb, :cover ]).each do |path|
            add_path_entry archive, path, file_root_folder.join(path.relative_path_from MEDIA_ELEMENTS_UPFOLDER)
          end

          documents_files.each do |path|
            add_path_entry archive, path, file_root_folder.join(path.relative_path_from DOCUMENTS_UPFOLDER)
          end

          math_images.each do |path|
            add_path_entry archive, path, file_math_images_folder.join(path.basename)
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

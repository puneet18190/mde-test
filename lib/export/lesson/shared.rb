require 'export'
require 'export/lesson'

module Export
  module Lesson
    module Shared
      MEDIA_ELEMENTS_UPFOLDER      = Rails.public_pathname
      DOCUMENTS_UPFOLDER           = Rails.public_pathname
      FILE_MATH_IMAGES_FOLDER_NAME = 'math_images'
      WRITE_TIME_FORMAT            = '%Y%m%d_%H%M%S_%Z_%N'

      private
      def media_elements_files(options = {})
        exclude_versions = options[:exclude_versions] || []
        lesson.media_elements.map{ |r| r.media.paths.reject{ |k| exclude_versions.include?(k) }.values.map{ |v| Pathname(v) } }.flatten
      end

      def documents_files
        lesson.documents.map{ |r| Pathname r.attachment.file.path }
      end

      def math_images
        lesson.math_images_paths(:full_path)
      end

      def add_path_entry(archive, path, entry_path)
        archive.add entry(path.to_s, entry_path.to_s), path
      end

      def add_string_entry(archive, string, entry_path)
        archive.get_output_stream(entry archive.name, entry_path.to_s) { |f| f.print string }
      end
      
      def entry(first_argument, second_argument)
        Zip::Entry.new first_argument, second_argument, '', '', 0, 0, self.class::COMPRESSION_METHOD
      end

      def remove_old_files
        Pathname.glob(folder.join '..', '*').each{ |path| FileUtils.rm_rf path }
      end
    end
  end
end

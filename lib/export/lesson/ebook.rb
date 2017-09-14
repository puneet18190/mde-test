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
    class Ebook
      require 'export/lesson/ebook/view'
      require 'export/lesson/shared/ebook_and_ebook_view'

      include EnvRelativePath
      include Shared
      include Shared::EbookAndEbookView

      OUTPUT_FOLDER            = env_relative_pathname Rails.public_pathname, 'lessons', 'exports', 'ebooks'
      SLIDES_INCLUDES          = [ :media_elements_slides, :media_elements ]
      SLIDES_EAGER_LOAD        = SLIDES_INCLUDES
      SLIDES_ORDER             = 'slides.position'
      FILE_CONTENTS_FOLDER     = Pathname 'OEBPS'
      FILE_INPUT_ASSETS_FOLDER = FILE_CONTENTS_FOLDER.join 'assets'

      INPUT_VIEWS_FOLDER = View::FOLDER

      INPUT_ASSETS_FOLDER = Lesson::FOLDER.join 'ebooks', 'assets'
      ASSETS_PATHS        = %W( lesson_ebook/application.css )

      # STORED or DEFLATED
      COMPRESSION_METHOD = Zip::Entry::STORED

      def self.remove_folder!
        FileUtils.rm_rf OUTPUT_FOLDER
      end

      attr_reader :lesson, :slides, :filename_without_extension, :output_folder, :filename, :output_path

      def initialize(lesson)
        @lesson = lesson
        @slides = lesson.slides.order(:position)

        parameterized_title = lesson.title.parameterize
        time                = lesson.updated_at.utc.strftime(WRITE_TIME_FORMAT)

        @filename_without_extension = lesson.id.to_s.tap{ |s| s << "_#{parameterized_title}" if parameterized_title.present? }
        @output_folder              = OUTPUT_FOLDER.join lesson.id.to_s, time
        @filename                   = "#{filename_without_extension}.epub"
        @output_path                       = output_folder.join filename
      end

      def url
        find_or_create

        "/#{output_path.relative_path_from Rails.public_pathname}"
      end

      def find_or_create
        return if output_path.exist?
        
        # raises if export assets are not compiled
        raise "Assets are not compiled. Please create them using rake exports:lessons:ebooks:assets:compile" unless assets_compiled?

        remove_old_files if output_folder.exist?
        output_folder.mkpath
        create

        self
      end

      private

      def create
        Zip::File.open(output_path, Zip::File::CREATE) do |archive|
          add_path_entry archive, view_path('mimetype'), 'mimetype'

          add_path_entry archive, view_path('META-INF/container.xml'), 'META-INF/container.xml'

          locals = { lesson: lesson, slides: slides }

          add_template archive, locals.merge(math_images: math_images), FILE_CONTENTS_FOLDER.join('package.opf')

          assets_files.each do |path|
            add_path_entry archive, path, FILE_INPUT_ASSETS_FOLDER.join(File.basename path.relative_path_from INPUT_ASSETS_FOLDER)
          end

          add_template archive, locals, FILE_CONTENTS_FOLDER.join('toc.xhtml')

          slides.each_with_object(FILE_CONTENTS_FOLDER.join 'slide.xhtml') do |slide, slide_view_path|
            add_template archive, { lesson: lesson, slide: slide }, FILE_CONTENTS_FOLDER.join(slide_filename slide), slide_view_path
          end

          media_elements_files(exclude_versions: [ :thumb ]).each do |path|
            add_path_entry archive, path, FILE_CONTENTS_FOLDER.join(path.relative_path_from MEDIA_ELEMENTS_UPFOLDER)
          end

          math_images.each do |path|
            add_path_entry archive, path, FILE_CONTENTS_FOLDER.join(math_image_path_relative_from_contents_folder path.basename)
          end
        end

        output_path.chmod 0644
      rescue
        output_path.unlink if output_path.exist?
        raise
      end

      def assets_compiled?
        INPUT_ASSETS_FOLDER.exist? && INPUT_ASSETS_FOLDER.entries.present?
      end

      def assets_files
        Pathname.glob( INPUT_ASSETS_FOLDER.join('**', '*') ).reject{ |path| path.directory? }
      end

      def add_template(archive, locals, archive_entry_path, view_path_relative_from_template_folder = nil)
        view_path_relative_from_template_folder ||= archive_entry_path

        add_string_entry archive                                                                                 ,
                         View.instance.render(template: view_path_relative_from_template_folder, locals: locals) ,
                         archive_entry_path
      end

      def view_path(path)
        INPUT_VIEWS_FOLDER.join path
      end

    end
  end
end


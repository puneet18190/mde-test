require 'media'
require 'media/similar_durations'
require 'securerandom'
require 'find'
require 'thread_proc'

module Media

  # Media uploading abstract class; ancestor of Media::Video::Uploader and Media::Audio::Uploader
  class Uploader < String
    include SimilarDurations

    # Record instance of the media
    attr_reader :model
    # Table column which will contain the media name
    attr_reader :column
    # Media value
    attr_reader :value

    # Media folder (relative to the app public/ folder, for using in URLs)
    PUBLIC_RELATIVE_MEDIA_ELEMENTS_FOLDER              = 'media_elements'
    # Absolute path to the media folders (for using in paths)
    MEDIA_ELEMENTS_FOLDER                              = Rails.public_pathname.join PUBLIC_RELATIVE_MEDIA_ELEMENTS_FOLDER
    # Maximum allowed size for media elements folder; if exceeded, upload gets disabled
    MAXIMUM_MEDIA_ELEMENTS_FOLDER_SIZE                 = SETTINGS['maximum_media_elements_folder_size'].gigabytes.to_i
    # Maximum size of a processed media filename extension. For our files is the "webm" extension size, that is 4.
    PROCESSED_FILENAME_MAX_EXTENSION_SIZE              = 4
    # Above plus "dot" (<tt>.</tt>) size
    PROCESSED_FILENAME_MAX_EXTENSION_SIZE_DOT_INCLUDED = PROCESSED_FILENAME_MAX_EXTENSION_SIZE + 1

    # Remove media folder (descendants)
    def self.remove_folder!
      FileUtils.rm_rf self::FOLDER
    end

    # Media folder size (descendants)
    def self.folder_size
      return 0 unless  Dir.exists? self::FOLDER
      Find.find(self::FOLDER).sum { |f| File.stat(f).size }
    end

    # Media folder size
    def self.media_elements_folder_size
      return 0 unless MEDIA_ELEMENTS_FOLDER.directory?
      Find.find(MEDIA_ELEMENTS_FOLDER.to_s).sum { |f| File.stat(f).size }
    end

    # Whether the media folder size exceeds the maximum size or not
    def self.maximum_media_elements_folder_size_exceeded?
      media_elements_folder_size > MAXIMUM_MEDIA_ELEMENTS_FOLDER_SIZE
    end

    # Called by the relative model attribute setter and getter
    #
    # ### Args
    #
    # * *model*: instance to which the media supplied will be associated
    # * *column*: column of the record table which will contain the media name
    # * *value*: value of the media; it supports instances of the following classes:
    #   * +String+
    #   * +File+
    #   * +ActionDispatch::Http::UploadedFile+
    #   * +Hash+
    def initialize(model, column, value)
      @model, @column, @value = model, column, value

      case @value
      when String
        @filename_without_extension = File.basename @value
      when File
        @original_file     = @value
        @original_filename = File.basename @value.path
        model.converted    = false
      when ActionDispatch::Http::UploadedFile
        @original_file     = @value.tempfile
        @original_filename = @value.original_filename
        model.converted    = false
      when Hash
        @converted_files                     = @value.select{ |k| formats.include? k }
        @original_filename_without_extension = @value[:filename]
        formats.each { |f| instance_variable_set :"@#{duration_keys[f]}", @value[ duration_keys[f] ] }
        version_formats.each{ |v, _| instance_variable_set :"@#{version_input_path_keys[v]}", @value[ version_input_path_keys[v] ] }
      else
        @filename_without_extension ||= ''
      end
    end

    def size(format)
      File.size path(format)
    end

    # Filename of the media relative to the supplied format
    def filename(format)
      "#{filename_without_extension}.#{format}"
    end

    # Filename without the extension (related to the format)
    def filename_without_extension
      (@filename_without_extension || original_filename_without_extension).to_s
    end

    # Returns a new filename adding a token (provided by the model instance), adding the extension if provided
    def processed_filename(filename, extension = nil)
      suffix                      = "_#{model.filename_token}"
      max_processed_filename_size = max_processed_filename_size(suffix)
      filename_without_suffix     = filename.slice 0, max_processed_filename_size
      "#{filename_without_suffix.parameterize}#{suffix}".tap { |s| s << ".#{extension}" if extension }
    end

    def max_processed_filename_size(suffix)
      model.class.send("max_#{column}_column_size") - suffix.size - PROCESSED_FILENAME_MAX_EXTENSION_SIZE_DOT_INCLUDED
    end

    # Original filename after being processed by Media::Uploader.process
    def processed_original_filename
      processed_filename original_filename_without_extension, original_filename_extension
    end

    # Original filename after being processed by Media::Uploader.process without the extension
    def processed_original_filename_without_extension
      processed_filename original_filename_without_extension
    end

    # Original filename without the extension
    def original_filename_without_extension
      @original_filename_without_extension || File.basename(original_filename, original_filename_extension)
    end

    # Original filename
    def original_filename
      File.basename(@original_filename)
    end

    # Original filename extension
    def original_filename_extension
      File.extname(@original_filename)
    end

    # Returns +false+ (a Media::Uploader instance is never +blank?+)
    def blank?
      false
    end

    # Start the upload or the copy processing, depending on <tt>@value</tt>
    def upload_or_copy
      raise Error.new('model_id cannot be blank', model: @model, column: @column, value: @value) if model_id.blank?

      if @converted_files
        copy
      elsif @original_file
        upload
      end

      true
    end

    # Path where the uploaded/copied file will be written without the extension
    def output_path_without_extension
      File.join output_folder, processed_original_filename_without_extension
    end

    # Path where the uploaded/copied file will be written (related to the format)
    def output_path(format)
      "#{output_path_without_extension}.#{format}"
    end

    # Folder of the output path
    def folder
      File.join self.class::FOLDER, model_id.to_s
    end
    alias output_folder folder

    # Folder of the output path relative to the Rails static resources folder (in order to be used by URLs)
    def public_relative_folder
      File.join '/', self.class::PUBLIC_RELATIVE_FOLDER, model_id.to_s
    end

    # id of the model instance
    def model_id
      model.id
    end

    # Whether the value of the attribute of the instance is changed
    def column_changed?
      model.send(:"#{column}_changed?")
    end

    # Whether the value of the attribute of the instance can be renamed
    def rename?
      model.send(:"rename_#{column}")
    end

    # If the attribute is changed and can be renamed returns the processed filename, otherwise returns Media::Uploader#public_relative_path
    def to_s
      if column_changed? and rename?
        processed_filename @value.to_s
      else
        public_relative_path
      end
    end
    alias inspect to_s

    # Returns the public relative path related to the supplied format, or without extension if format is blank
    def public_relative_path(format = nil)
      File.join public_relative_folder, (
        case format
        when ->(f) { f.blank? }
          filename_without_extension
        when *formats
          filename(format)
        when *self.class::VERSION_FORMATS.keys
          self.class::VERSION_FORMATS[format] % filename_without_extension
        else
          ''
        end
      )
    end
    alias url public_relative_path

    # Absolute path of the file, related to the supplied +format+ (+format+ required)
    def path(format)
      case format
      when *formats
        File.join folder, filename(format)
      when *self.class::VERSION_FORMATS.keys
        File.join folder, self.class::VERSION_FORMATS[format] % filename_without_extension
      end
    end

    # Hash where the keys are the supported formats (version formats included) and the values the absolute paths of the media files
    def paths
      Hash[ (formats + self.class::VERSION_FORMATS.keys).map{ |f| [f, path(f)] } ]
    end

    # Hash where the keys are the supported formats (version formats excluded) plus a pair key => value where the key is +:filename+ and the value Media::Uploader#filename_without_extension
    def to_hash
      Hash[ formats.map{ |f| [f, path(f)] } ].merge(filename: filename_without_extension)
    end

    private
    # Instance-level alias of +self.class::VERSION_FORMATS+
    def version_formats
      self.class::VERSION_FORMATS
    end

    # Hash where the keys are the versions and the values are the keys to be used in the initializer in order to submit the version input paths
    def version_input_path_keys
      @version_input_path_keys ||= Hash[ version_formats.map{ |v, _| [ v, :"#{v}" ] } ]
    end

    # Hash where the keys are the versions and the values are the respective instance variable values
    def version_input_paths
      @version_input_paths ||= Hash[ version_input_path_keys.map{ |v, k| [ v, instance_variable_get(:"@#{k}") ] } ]
    end

    # Whether the version input paths have been provided or not
    def version_input_paths?
      version_input_paths.all?{ |_, version_input_path| version_input_path.present? }
    end

    # Instance-level alias of +self.class::FORMATS+
    def formats
      self.class::FORMATS
    end

    # Hash where the keys are the formats and the values are the keys to be used in the initializer in order to submit the durations
    def duration_keys
      @duration_keys ||= Hash[ formats.map{ |f| [ f, :"#{f}_duration" ] } ]
    end

    # Hash where the keys are the versions and the values are the respective instance variable values
    def durations
      @durations ||= Hash[ duration_keys.map{ |f, k| [ f, instance_variable_get(:"@#{k}") ] } ]
    end

    # Whether the durations have been provided or not
    def durations?
      durations.all?{ |_, duration| duration.present? }
    end

    # Executes the copy process
    def copy
      FileUtils.mkdir_p output_folder unless Dir.exists? output_folder
      
      infos = {}
      @converted_files.each do |format, input_path|
        output_path = output_path(format)
        # se il percorso del file è uguale a quello vecchio è lo stesso file; per cui non copio
        # (è un caso che si verifica p.e. nel caso di un errore nel Composer, che ripristina il file vecchio)
        FileUtils.cp input_path, output_path if input_path != output_path

        model.send :"#{format}_duration=", 
          if durations?
            durations[format]
          else
            info = Info.new(output_path)
            infos[format] = info
            info.duration
          end
      end

      extract_versions(infos)

      model.converted = true
      model.send :"rename_#{column}=", true
      model.send :"#{column}=", processed_original_filename_without_extension
      model[column] = processed_original_filename_without_extension
      model.save!

      model.send :"rename_#{column}=", nil
      model.skip_conversion = nil
      model.send :"reload_#{column}"

      true
    end

    # Implemented by the descendant classes in order to extract the versions needed (used by Media::Uploader.copy)
    def extract_versions(infos)
      raise NotImplementedError
    end

    # Executes the copy of the uploaded file to the temporary folder and add related job to the jobs queue
    def upload_copy_and_job(conversion_temp_path)
      FileUtils.cp @original_file.path, conversion_temp_path
      Delayed::Job.enqueue self.class::CONVERSION_CLASS::Job.new(@original_file.path, output_path_without_extension, original_filename, model_id)
    end

    # Executes the upload process
    def upload
      return if model.skip_conversion

      conversion_temp_path = self.class::CONVERSION_CLASS.temp_path(model_id, original_filename)

      FileUtils.mkdir_p File.dirname(conversion_temp_path)

      # FIXME Test environment doesn't use delayed_job, so parallel execution breaks tests
      Rails.env.test? ? upload_copy_and_job(conversion_temp_path) : Thread.new(&ThreadProc.new { upload_copy_and_job(conversion_temp_path) })
    end
  end
end

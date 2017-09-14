require 'csv'

require 'env_relative_path'

class Seeds
  include EnvRelativePath

  def self.environment_paths(path)
    ENVIRONMENT_PATHS.map{ |v| v.join path }
  end

  # If suffix exists, it will be appended at the end of each path with a path join before to detect the first existing path
  def self.first_existing_path(paths, suffix = nil)
    paths = paths.map { |v| v.join suffix } if suffix
    paths.detect { |path| path.exist? }
  end
  
  # Paths searchable for seeds files
  ENVIRONMENT_PATHS = Rails.application.config.paths[ Rails.application.config.db_seeds_enviroment_path ].expanded.map{ |v| Pathname(v) }

  # Folder containing csv
  CSV_FOLDERS = environment_paths 'csv'
  # Options for the csv loading
  CSV_OPTIONS = { headers: true }

  # Public media element folders
  PUBLIC_MEDIA_ELEMENTS_FOLDERS     = [ Media::Video::Uploader, Media::Audio::Uploader, ImageUploader ].map{ |u| u.const_get(:FOLDER) }
  # Folder where backups of media elements are stored
  OLD_PUBLIC_MEDIA_ELEMENTS_FOLDERS = Hash[ PUBLIC_MEDIA_ELEMENTS_FOLDERS.map{ |f| [ f, "#{f}.old" ] } ]

  # Normal folder of media elements
  MEDIA_ELEMENTS_FOLDER = environment_paths 'media_elements'

  # AUDIOS_FOLDER, VIDEOS_FOLDER, IMAGES_FOLDER
  %w(audios videos images).each do |media_folder|
    const_set :"#{media_folder.upcase}_FOLDER", first_existing_path( MEDIA_ELEMENTS_FOLDER, env_relative_pathname(media_folder) )
  end

  # Public documents folder
  PUBLIC_DOCUMENTS_FOLDER     = DocumentUploader::FOLDER
  # Folder where backups of documents are stored
  OLD_PUBLIC_DOCUMENTS_FOLDER = "#{DocumentUploader::FOLDER}.old"

  # Folder of documents
  DOCUMENTS_FOLDER = first_existing_path environment_paths 'documents'

  # Pepper code
  PEPPER = '3e0e6d5ebaa86768a0a51be98fce6367e44352d31685debf797b9f6ccb7e2dd0f5139170376240945fcfae8222ff640756dd42645336f8b56cdfe634144dfa7d'
    
  # List of models to seed
  MODELS = [ Location, SchoolLevel, Subject, Purchase, User, Document, MediaElement, Lesson, Slide, MediaElementsSlide, DocumentsSlide, Like, Bookmark ]

  def run
    puts "Applying #{Rails.env} seeds (#{MODELS.map{ |m| humanize_table_name(m.table_name) }.join(', ')})"
    backup_old_media_elements_folders
    backup_old_documents_folder
    ActiveRecord::Base.transaction do
      MODELS.each do |model|
        @model, @table_name = model, model.table_name
        set_rows_amount
        send :"#{@table_name}!"
        update_sequence
      end
      remove_old_media_elements_folders
      remove_old_documents_folder
    end
    replace_pepper
    puts 'End.'
  rescue StandardError => e
    restore_old_media_elements_folders
    restore_old_documents_folder
    raise e
  end
  
  private
  
  def replace_pepper
    return if User::Authentication::PEPPER == PEPPER
    old_pepper = "#{User::Authentication::PEPPER_PATH}.old"
    pepper = User::Authentication::PEPPER_PATH
    warn "The pepper doesn't correspond to the seeds pepper; replacing" 
    warn "Moving #{pepper} to #{old_pepper}"
    FileUtils.mv pepper, old_pepper
    pepper.open('w') { |io| io.write PEPPER }
    User::Authentication.const_set :PEPPER, PEPPER
  end
  
  def backup_old_documents_folder
    remove_old_documents_folder
    begin
      FileUtils.mv PUBLIC_DOCUMENTS_FOLDER, OLD_PUBLIC_DOCUMENTS_FOLDER
    rescue Errno::ENOENT
    end
  end
  
  def remove_old_documents_folder
    FileUtils.rm_rf OLD_PUBLIC_DOCUMENTS_FOLDER
  end
  
  def restore_old_documents_folder
    begin
      FileUtils.rm_rf PUBLIC_DOCUMENTS_FOLDER
      FileUtils.mv OLD_PUBLIC_DOCUMENTS_FOLDER, PUBLIC_DOCUMENTS_FOLDER
    rescue Errno::ENOENT
    end
  end
  
  def backup_old_media_elements_folders
    remove_old_media_elements_folders
    PUBLIC_MEDIA_ELEMENTS_FOLDERS.each_with_index do |f|
      begin
        FileUtils.mv f, OLD_PUBLIC_MEDIA_ELEMENTS_FOLDERS[f]
      rescue Errno::ENOENT
      end
    end
  end
  
  def remove_old_media_elements_folders
    OLD_PUBLIC_MEDIA_ELEMENTS_FOLDERS.values.each{ |of| FileUtils.rm_rf of }
  end
  
  def restore_old_media_elements_folders
    OLD_PUBLIC_MEDIA_ELEMENTS_FOLDERS.each do |f, of|
      begin
        FileUtils.rm_rf f
        FileUtils.mv of, f
      rescue Errno::ENOENT
      end
    end
  end
  
  def humanize_table_name(table_name = @table_name)
    table_name.tr('_', ' ')
  end
  
  def csv_path(filename = @table_name)
    filename += '.csv'
    csv_path = self.class.first_existing_path CSV_FOLDERS, filename
    raise "Can't find the file #{filename} inside #{CSV_FOLDERS.join(', ')}" unless csv_path
    csv_path
  end
  
  def csv_open(csv_path = csv_path)
    CSV.open(csv_path, CSV_OPTIONS)
  end
  
  def users_subjects(id)
    csv_open(csv_path('users_subjects')).each.select do |row|
      row['user_id'] == id.to_s
    end.map do |row|
      row['subject_id']
    end
  end
  
  def media(record, row)
    case record
    when Audio
      v = Pathname.glob(AUDIOS_FOLDER.join record.id.to_s, '*.m4a').first
      n = v.basename(v.extname).to_s # .gsub /_.*/, ''
      { m4a: v.to_s, ogg: v.sub_ext('.ogg').to_s, filename: n, 
        m4a_duration: row['m4a_duration'].try(:to_f), ogg_duration: row['ogg_duration'].try(:to_f) }
    when Video
      f = VIDEOS_FOLDER.join record.id.to_s
      v = Pathname.glob(f.join '*.mp4').first
      c = Pathname.glob(f.join 'cover_*.jpg').first.try(:to_s)
      t = Pathname.glob(f.join 'thumb_*.jpg').first.try(:to_s)
      n = v.basename(v.extname).to_s # .gsub /_.*/, ''
      { mp4: v.to_s, webm: v.sub_ext('.webm').to_s, filename: n,
        mp4_duration: row['mp4_duration'].try(:to_f), webm_duration: row['webm_duration'].try(:to_f), cover: c, thumb: t }
    when Image
      File.open Pathname.glob(IMAGES_FOLDER.join(record.id.to_s, Image::EXTENSIONS_GLOB), File::FNM_CASEFOLD).first
    end
  end
  
  def attachment(id)
    path =
      case Rails.env
      when 'production'
        Pathname.glob(DOCUMENTS_FOLDER.join id.to_s, '*').first
      else
        DOCUMENTS_FOLDER.join(
          case id % 6
            when 0 then 'doc1.ppt'
            when 1 then 'doc2.pdf'
            when 2 then 'doc3.tar.gz'
            when 3 then 'doc4.ods'
            when 4 then 'doc5.svg'
            when 5 then 'doc6.txt'
          end )
      end
    File.open path
  end
  
  def tags(id)
    csv_open(csv_path('taggings')).each.select do |row|
      row['taggable_type'] == @model.to_s && row['taggable_id'] == id.to_s
    end.map do |taggable_row|
      csv_open(csv_path('tags')).each.find{ |tags_row| taggable_row['tag_id'] == tags_row['id'] }['word']
    end.join(',')
  end
  
  def csv_row_to_record(row, model = @model, skip = [])
    model.new do |record|
      row.headers.reject{ |h| skip.include? h }.each { |header| record.send :"#{header}=", row[header] }
    end
  end
  
  def update_sequence
    @model.connection.reset_pk_sequence! @table_name
  end
  
  def progress(i)
    n = i+1
    $stdout.print "  saving #{n.ordinalize} of #{@rows_amount} #{humanize_table_name}\r"
    $stdout.flush
    return if n != @rows_amount
    $stdout.puts
    $stdout.flush
  end
  
  def set_rows_amount
    @rows_amount = csv_open.readlines.count
  end
  
  def locations!
    csv_open.each.each_with_index do |row, i|
      progress(i)
      csv_row_to_record(row).save!
    end
  end
  
  def school_levels!
    csv_open.each.each_with_index do |row, i|
      progress(i)
      csv_row_to_record(row).save!
    end
  end
  
  def subjects!
    csv_open.each.each_with_index do |row, i|
      progress(i)
      csv_row_to_record(row).save!
    end
  end
  
  def users!
    csv_open.each.each_with_index do |row, i|
      progress(i)
      record = csv_row_to_record(row)
      record.subject_ids = users_subjects(record.id)
      record.accept_policies
      record.save!
    end
  end
  
  def purchases!
    csv_open.each.each_with_index do |row, i|
      progress(i)
      record = csv_row_to_record(row)
      record.save!
    end
  end
  
  def media_elements!
    csv_open.each.each_with_index do |row, i|
      progress(i)
      record = csv_row_to_record row, row['sti_type'].constantize, %w(mp4_duration webm_duration m4a_duration ogg_duration)
      record.media                   = media(record, row)
      record.skip_public_validations = true
      record.tags                    = tags(record.id)
      record.save_tags               = true
      record.save!
    end
  end
  
  def lessons!
    csv_open.each.each_with_index do |row, i|
      progress(i)
      record = csv_row_to_record(row)
      record.skip_public_validations = true
      record.skip_cover_creation     = true
      record.tags                    = tags(record.id)
      record.save_tags               = true
      record.save!
    end
  end
  
  def documents!
    csv_open.each.each_with_index do |row, i|
      progress(i)
      record = csv_row_to_record(row)
      record.attachment = attachment(record.id)
      record.save!
    end
  end
  
  def documents_slides!
    csv_open.each.each_with_index do |row, i|
      progress(i)
      record = csv_row_to_record(row)
      record.save!
    end
  end
  
  def slides!
    csv_open.each.each_with_index do |row, i|
      progress(i)
      csv_row_to_record(row).save!
    end
  end
  
  def media_elements_slides!
    csv_open.each.each_with_index do |row, i|
      progress(i)
      csv_row_to_record(row).save!
    end
  end
  
  def likes!
    csv_open.each.each_with_index do |row, i|
      progress(i)
      csv_row_to_record(row).save!
    end
  end
  
  def bookmarks!
    csv_open.each.each_with_index do |row, i|
      progress(i)
      csv_row_to_record(row).save!
    end
  end
  
end

Seeds.new.run

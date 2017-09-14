require 'spec_helper'

describe Video, slow: true do
  def media_folder
    @media_folder ||= Rails.root.join('spec/support/samples')
  end

  def media_without_extension
    @media_without_extension ||= media_folder.join('con verted').to_s
  end

  def tmp_valid_video_path
    @tmp_valid_video_path ||= media_folder.join 'tmp.valid video.flv'
  end

  def media_uploaded
    @media_uploaded ||= ActionDispatch::Http::UploadedFile.new(filename: File.basename(tmp_valid_video_path), tempfile: tmp_valid_video_path.open)
  end

  def media_hash
    @media_hash ||= { filename: 'tmp.valid video', mp4: "#{media_without_extension}.mp4", webm: "#{media_without_extension}.webm" }
  end

  def record
    @record ||= described_class.new(title: 'title', description: 'description', tags: 'a,b,c,d,e', media: media_uploaded, user: User.admin)
  end

  def short_media_filename_size
    nil
  end

  def saved
    FileUtils.cp MESS::VALID_VIDEO, tmp_valid_video_path
    record.save!
    record
  end

  let(:valid_video_path) { media_folder.join 'valid video.flv' }

  describe '#save' do
    let(:media_type) { 'video' }
    let(:urls)       { { mp4:   [ url_without_extension, ".mp4"  ], 
                         webm:  [ url_without_extension, ".webm" ],
                         cover: [ "#{public_relative_folder}/cover_#{name}", ".jpg" ], 
                         thumb: [ "#{public_relative_folder}/thumb_#{name}", ".jpg" ] } }
    let(:paths)      { { mp4:   [ path_without_extension, ".mp4"  ], 
                         webm:  [ path_without_extension, ".webm" ],
                         cover: [ "#{folder}/cover_#{name}", ".jpg" ], 
                         thumb: [ "#{folder}/thumb_#{name}", ".jpg" ] } }

    before(:all) { saved.reload }

    include_examples 'after saving an audio or a video with a valid not converted media'
    include_examples 'after saving a video with a valid not converted media'
  end

  describe '#destroy' do
    def record
      @record ||= described_class.new(title: 'title', description: 'description', tags: 'a,b,c,d,e', media: media_hash, user: User.admin)
    end

    before(:all) { saved.reload.destroy }

    let(:output_folder) { "#{Rails.root}/public/media_elements/videos/test/#{record.id}" }

    it 'gets destroyed' do
      expect(described_class.find_by_id(record.id)).to be_nil
    end

    it 'destroys the video folder' do
      expect(File.exist?(output_folder)).to be false
    end
  end

  after(:all) do
    FileUtils.rm tmp_valid_video_path if File.exists? tmp_valid_video_path
  end
end
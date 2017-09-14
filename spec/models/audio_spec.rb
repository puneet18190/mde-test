require 'spec_helper'

describe Audio, slow: true do
  def media_folder
    @media_folder ||= Rails.root.join('spec/support/samples')
  end


  def tmp_valid_audio_path
    @tmp_valid_audio_path ||= media_folder.join 'tmp.valid audio.m4a'
  end

  def record
    @record ||= begin
      media = ActionDispatch::Http::UploadedFile.new(filename: File.basename(tmp_valid_audio_path), tempfile: File.open(tmp_valid_audio_path))
      described_class.new(title: 'title', description: 'description', tags: 'a,b,c,d,e', media: media, user: User.admin)
    end
  end

  def short_media_filename_size
    nil
  end

  def saved
    FileUtils.cp MESS::VALID_AUDIO, tmp_valid_audio_path
    record.save!
    record
  end

  let(:valid_audio_path) { media_folder.join 'valid audio.m4a' }

  describe '#save' do
    let(:media_type) { 'audio' }
    let(:urls)       { { m4a: [ url_without_extension,  ".m4a" ],
                         ogg: [ url_without_extension,  ".ogg" ] } }
    let(:paths)      { { m4a: [ path_without_extension, ".m4a" ], 
                         ogg: [ path_without_extension, ".ogg" ] } }

    before(:all) { saved.reload }

    include_examples 'after saving an audio or a video with a valid not converted media'
  end

  describe '#destroy' do
    before(:all) { saved.reload.destroy }

    let(:output_folder) { "#{Rails.root}/public/media_elements/audios/test/#{record.id}" }

    it 'gets destroyed' do
      expect(described_class.find_by_id(record.id)).to be_nil
    end

    it 'destroys the audio folder' do
      expect(File.exist?(output_folder)).to be false
    end
  end

  after(:all) do
    FileUtils.rm tmp_valid_audio_path if File.exists? tmp_valid_audio_path
  end
end
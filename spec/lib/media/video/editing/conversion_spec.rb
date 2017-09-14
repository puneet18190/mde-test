require 'spec_helper'
require 'shellwords'

module Media
  module Video
    module Editing
      describe Conversion, slow: true do
  
        supported_formats = MESS::VIDEO_FORMATS
  
        def uploaded_path
          @uploaded_path ||= "#{MESS::SAMPLES_FOLDER}/tmp.in put.flv"
        end
        
        def filename
          @filename ||= 'in put.flv'
        end

        def tempfile
          @tempfile ||= File.open(uploaded_path)
        end

        def uploaded
          @uploaded ||= ActionDispatch::Http::UploadedFile.new(filename: filename, tempfile: tempfile)
        end

        def model
          @model ||= ::Video.new(title: 'title', description: 'description', tags: 'a,b,c,d,e', media: uploaded) do |video|
            video.user_id = User.admin.id
          end.tap{ |v| v.skip_conversion = true; v.save!; v.media = uploaded }
        end

        def temp
          @temp ||= "#{Rails.root}/tmp/media/video/editing/conversions/#{Rails.env}/#{model.id}/#{filename}"
        end

        def output_folder
          @output_folder ||= "#{Rails.root}/public/media_elements/videos/#{Rails.env}/#{model.id}"
        end

        def output_without_extension
          @output_without_extension ||= "#{output_folder}/in-put"
        end

        def stdout_log
          @stdout_log ||= "#{Rails.root}/log/media/video/editing/conversions/#{Rails.env}/#{model.id}/#{format}.stdout.log"
        end

        def stderr_log
          @stderr_log ||= "#{Rails.root}/log/media/video/editing/conversions/#{Rails.env}/#{model.id}/#{format}.stderr.log"
        end

        let(:output) { "#{output_without_extension}.#{format}" }
  
        describe '#convert_to' do
  
          supported_formats.each do |format|
            context "with #{format} format", format: format do
  
              class_eval <<-RUBY
                def format
                  @format ||= #{format.inspect}
                end
              RUBY
  
              [ [ :valid_video,               MESS::VALID_VIDEO ],
                [ :valid_video_with_odd_size, MESS::VALID_VIDEO_WITH_ODD_SIZE ] ].each do |video_data|
  
                video, video_constant = video_data
  
                context "with a #{video.to_s.humanize.downcase}" do
  
                  def conversion
                    @conversion ||= described_class.new(uploaded_path, output_without_extension, filename, model.id)
                  end
  
                  def subject
                    @subject ||= conversion.convert_to(format)
                  end
  
                  before(:all) do
                    FileUtils.cp video_constant, uploaded_path
                    [ stdout_log, stderr_log, temp, output_folder ].each { |f| FileUtils.rm(f) if File.exists?(f) }
                    subject
                  end
  
                  it "creates a valid video" do
                    expect{ Info.new(output) }.to_not raise_error
                  end
  
                  it 'creates a video with the expected duration' do
                    temp_duration, output_duration = Info.new(temp).duration, Info.new(output).duration
                    expect(temp_duration).to be_within(described_class::DURATION_THRESHOLD).of(output_duration)
                  end
  
                  it 'has the expected stdout_log path' do
                    expect(conversion.send(:stdout_log, format)).to eq stdout_log
                  end
  
                  it 'has the expected stderr_log path' do
                    expect(conversion.send(:stderr_log, format)).to eq stderr_log
                  end
  
                  it "creates the stdout log" do
                    expect(File.exists?(stdout_log)).to be true
                  end
  
                  it "creates the stderr log" do
                    expect(File.exists?(stderr_log)).to be true
                  end
  
                  it "does not delete the temporary video" do
                    expect(File.exists?(temp)).to be true
                  end
                
                end
  
              end
  
              context 'with an invalid video' do
  
                subject { described_class.new(uploaded_path, output_without_extension, filename, model.id) }
                
                before do
                  FileUtils.cp MESS::VALID_VIDEO, uploaded_path
                  model
                  FileUtils.cp MESS::INVALID_VIDEO, uploaded_path
                  FileUtils.rm(temp) if File.exists?(temp)
                end
  
                it { expect { subject.convert_to(format) }.to raise_error(Error) }
  
              end
  
              context 'when uploaded_path file and temporary file do not exist' do
  
                subject { described_class.new(uploaded_path, output_without_extension, filename, model.id) }
  
                before do
                  FileUtils.cp MESS::VALID_VIDEO, uploaded_path
                  model.media = uploaded
                  FileUtils.rm uploaded_path if File.exists? uploaded_path
                  subject
                  FileUtils.rm temp if File.exists? temp
                end
  
                it{ expect{ subject.convert_to(format) }.to raise_error(Error) }
  
              end
  
            end
          end
  
        end
  
        describe '#run' do
  
          def subject
            @subject ||= described_class.new(uploaded_path, output_without_extension, filename, model.id)
          end
  
          context 'with a valid video' do
        
            before(:all) do
              FileUtils.cp MESS::VALID_VIDEO, uploaded_path
              FileUtils.rm temp if File.exists? temp
              subject.run
              model.reload
            end
  
            it 'sets the model converted attribute' do
              expect(model).to be_converted
            end
  
            supported_formats.each do |format|
              context "with #{format} format", format: format do
  
                let(:format) { format }
  
                def info(format)
                  @info ||= {}
                  @info[format] ||= Info.new(output)
                end
  
                it "creates a valid video" do
                  expect{ info(format) }.to_not raise_error
                end
  
                it 'creates the video cover' do
                  expect(File.exists?(model.media.path(:cover))).to be true
                end
  
                it 'creates the video thumb' do
                  expect(File.exists?(model.media.path(:thumb))).to be true
                end
  
                it 'sets the model duration attribute' do
                  expect(model.send(:"#{format}_duration")).to be_within(0.2).of info(format).duration
                end
  
              end
            end
  
            it 'sets the model media attribute' do
              expect(model[:media]).to eq 'in-put'
            end
  
            it 'deletes the temporary file' do
              expect(File.exist?(temp)).to be false
            end
  
          end
        end
  
        after(:all) do
          FileUtils.rm uploaded_path if File.exists? uploaded_path
          begin
            FileUtils.rm temp
          rescue Errno::ENOENT
          end
        end
  
      end
    end
  end
end

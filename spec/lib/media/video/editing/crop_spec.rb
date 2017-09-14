require 'spec_helper'

module Media
  module Video
    module Editing
      describe Crop do
  
        describe '.new' do
          subject { described_class.new(inputs, output_without_extension, start, duration) }
  
          let(:inputs)                   { { mp4: 'input', webm: 'input' } }
          let(:output_without_extension) { 'output' }
          let(:start)                    { 0 }
          let(:duration)                 { 10 }
  
          context 'when inputs are not an Hash' do
            let(:inputs) { nil }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when inputs have not the right keys' do
            let(:inputs) { { ciao: 'input' } }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when inputs are not strings' do
            let(:inputs) { { mp4: nil, webm: nil } }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when output_without_extension is not a String' do
            let(:output_without_extension) { nil }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when start is not a Numeric' do
            let(:start) { nil }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when start is a Numeric < 0' do
            let(:start) { -1 }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when start is not a Numeric' do
            let(:duration) { nil }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when duration is a Numeric <= 0' do
            let(:duration) { 0 }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when everything is in its right place' do
            it { expect { subject }.to_not raise_error }
          end
        end
  
        describe '#run' do
  
          def tmp_dir
            @tmp_dir ||= Dir.mktmpdir
          end
          
          def output
            @output ||= File.join tmp_dir, 'out put'
          end
  
          def subject
            @subject ||= described_class.new(MESS::CROP_VIDEOS, output, 10, 10).run
          end
  
          before(:all) { subject }
  
          MESS::VIDEO_FORMATS.each do |format|
  
            context "with #{format} format", format: format do
              let(:format) { format }
              let(:info)   { Info.new(subject[format]).to_hash }
  
              it 'creates a video with the expected duration' do
                duration = info[:duration]
                expect(duration).to be_within(0.5).of(10)
              end
            end
  
          end
  
          after(:all) do
            if @tmp_dir 
              begin
                FileUtils.remove_entry_secure(@tmp_dir)
              ensure
                @tmp_dir = nil
              end
            end
          end
          
        end
      end
    end
  end
end

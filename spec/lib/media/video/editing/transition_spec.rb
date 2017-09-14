require 'spec_helper'

module Media
  module Video
    module Editing
      describe Transition do
  
        describe '.new' do
          subject { described_class.new(start_inputs, end_inputs, output_without_extension) }
  
          let(:valid_inputs) { { mp4: 'input', webm: 'input' } }
  
          let(:output_without_extension) { 'output' }
  
          context 'when inputs are not an Hash' do
            let(:start_inputs) { nil }
            let(:end_inputs)   { nil }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when start_input is not an Hash' do
            let(:start_inputs) { nil }
            let(:end_inputs)   { valid_inputs }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when end_input is not an Hash' do
            let(:start_inputs) { valid_inputs }
            let(:end_inputs)   { nil }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when inputs have not the right keys' do
            let(:start_inputs) { { ciao: 'input' } }
            let(:end_inputs)   { { ola:  'input' } }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when start_input have not the right keys' do
            let(:start_inputs) { { ciao: 'input' } }
            let(:end_inputs)   { valid_inputs }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when end_input have not the right keys' do
            let(:start_inputs) { valid_inputs }
            let(:end_inputs)   { { ola:  'input' } }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when inputs are not Strings' do
            let(:start_inputs) { { mp4: nil, webm: nil } }
            let(:end_inputs)   { { mp4: nil, webm: nil } }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when start_input are not Strings' do
            let(:start_inputs) { { mp4: nil, webm: nil } }
            let(:end_inputs)   { valid_inputs }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when end_input are not Strings' do
            let(:start_inputs) { valid_inputs }
            let(:end_inputs)   { { mp4: nil, webm: nil } }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when output_without_extension is not a String' do
            let(:start_inputs) { valid_inputs }
            let(:end_inputs)   { valid_inputs }
  
            let(:output_without_extension) { nil }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when inputs have the right keys and the right values' do
            let(:start_inputs) { valid_inputs }
            let(:end_inputs)   { valid_inputs }
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
  
          context "with valid videos" do
  
            def start_inputs
              @start_inputs ||= MESS::TRANSITION_VIDEOS[:start_inputs]
            end

            def end_inputs
              @end_inputs ||= MESS::TRANSITION_VIDEOS[:end_inputs]
            end

            def transition
              @transition ||= described_class.new(start_inputs, end_inputs, output)
            end
  
            def subject
              @subject ||= transition.run
            end
  
            before(:all) { subject }
  
            it 'has the expected log folder' do
              expect(transition.send(:log_folder)).to start_with Rails.root.join('log/media/video/editing/transition/test/').to_s
            end
  
            MESS::VIDEO_FORMATS.each do |format|
  
              context "with #{format} format", format: format do
  
                let(:format)      { format }
                let(:output_info) { Info.new(subject[format]).to_hash }
  
                it 'creates a video with the expected duration' do
                  expected_duration = Rational(described_class::INNER_FRAMES_AMOUNT+2, described_class::FRAME_RATE)
                  expect(output_info[:duration]).to eq expected_duration
                end
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

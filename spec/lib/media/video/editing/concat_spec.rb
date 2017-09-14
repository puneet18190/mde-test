require 'spec_helper'

module Media
  module Video
    module Editing
      describe Concat, slow: true do
  
        describe '.new' do
          let(:output_without_extension) { 'output' }
  
          subject { described_class.new(inputs, output_without_extension) }
  
          context 'when inputs is not an Array' do
            let(:inputs) { nil }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when inputs is an Hash with the wrong keys' do
            let(:inputs) { [ { webm: 'input', ciao: 'input'} ] }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when there is some inputs value which is not an hash' do
            let(:inputs) { [ { webm: 'input', mp4: 'input'}, nil ] }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when inputs are not paired' do
            let(:inputs) { [ { webm: 'input', mp4: 'input'}, { webm: 'input' } ] }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when at least one value of the inputs is empty' do
            let(:inputs) { [ { webm: 'input', mp4: nil } ] }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when output_without_extension is not a string' do
            let(:inputs) { [ { webm: 'input', mp4: 'input'} ] }
  
            let(:output_without_extension) { nil }
            it { expect { subject }.to raise_error Error }
          end
  
          context 'when inputs values is an Hash with the right keys and paired values' do
            context 'with one pair of values' do
              let(:inputs) { [{ webm: 'input', mp4: 'input'} ] }
              it { expect { subject }.to_not raise_error }
            end
  
            context 'with two pairs of values' do
              let(:inputs) { [ { webm: 'input', mp4: 'input' }, { webm: 'input', mp4: 'input' } ] }
              it { expect { subject }.to_not raise_error }
            end
          end
  
        end
  
        describe '#run' do
  
          context 'with a single couple of input_videos' do
  
            def tmp_dir
              @tmp_dir ||= Dir.mktmpdir
            end

            def output
              @output ||= File.join tmp_dir, 'out put'
            end

            def input_videos
              @input_videos ||= MESS::CONCAT_VIDEOS[:videos_with_some_audio_streams][:videos][0, 1]
            end

            def concat
              @concat ||= described_class.new(input_videos, output)
            end
            
            def subject
              @subject ||= concat.run
            end
  
            before(:all) { subject }
  
            it 'has the expected log folder' do
              expect(concat.send(:stdout_log)).to start_with Rails.root.join('log/media/video/editing/concat/test/').to_s
            end
  
            MESS::VIDEO_FORMATS.each do |format|
  
              context "with #{format} format", format: format do
  
                let(:format) { format }
              
                it 'copies the inputs to the outputs' do
                  expect(FileUtils.cmp(input_videos.first[format], subject[format])).to be true
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
  
          MESS::CONCAT_VIDEOS.each do |description, other_infos|
            input_videos, output_infos = other_infos[:videos], other_infos[:output_infos]
  
            context "with #{description.to_s.gsub('_',' ')}" do

              class_eval <<-RUBY
                def input_videos
                  @input_videos ||= #{other_infos[:videos].inspect}
                end
              RUBY
            
              def tmp_dir
                @tmp_dir ||= Dir.mktmpdir
              end

              def output
                @output ||= File.join tmp_dir, 'out put'
              end
  
              MESS::VIDEO_FORMATS.each do |format|
  
                context "with #{format} format", format: format do
  
                  def concat
                    @concat ||= described_class.new(input_videos, output)
                  end

                  def subject
                    @subject ||= concat.run
                  end
                  
                  let(:format) { format }
                  let(:info)   { Info.new(subject[format]).to_hash }
                  
  
                  before(:all) { subject }
  
                  it 'has the expected log folder' do
                    expect(concat.send(:stdout_log)).to start_with Rails.root.join('log/media/video/editing/concat/test/').to_s
                  end
  
                  it 'creates a video with the expected duration' do
                    duration = info[:duration]
                    expected = output_infos[format][:duration]
                    expect(duration).to be_within(0.2).of(expected)
                  end
  
                  it 'creates a video with the expected amount of video streams' do
                    video_streams = info[:streams][:video]
                    expected      = output_infos[format][:streams][:video]
                    expect(video_streams).to have(expected.size).items
                  end
                  it 'creates a video with the expected video stream codec and sizes' do
                    codec_and_sizes = info[:streams][:video].first.select{ |k| [:codec, :width, :height].include? k }
                    expected        = output_infos[format][:streams][:video].first.select{ |k| [:codec, :width, :height].include? k }
                    expect(codec_and_sizes).to eq expected
                  end
                  it 'creates a video with the expected video stream bitrate' do
                    bitrate  = info[:streams][:video].first[:bitrate]
                    expected = output_infos[format][:streams][:video].first[:bitrate]
                    if expected
                      expect(bitrate).to be_within(2).of(expected)
                    else
                      expect(bitrate).to be_nil
                    end
                  end
  
                  it 'creates a video with the expected amount of audio streams' do
                    audio_streams = info[:streams][:audio]
                    expected      = output_infos[format][:streams][:audio]
                    expect(audio_streams).to have(expected.size).items
                  end
                  it 'creates a video with the expected audio stream codec' do
                    codec    = info[:streams][:audio].first.try(:select) { |k| [:codec].include? k }
                    expected = output_infos[format][:streams][:audio].first.try(:select) { |k| [:codec].include? k }
                    expect(codec).to eq expected
                  end
                  it 'creates a video with the expected audio stream bitrate' do
                    bitrate  = info[:streams][:audio].first.try(:[], :bitrate)
                    expected = output_infos[format][:streams][:audio].first.try(:[], :bitrate)
                    if expected
                      expect(bitrate).to be_within(1).of(expected)
                    else
                      expect(bitrate).to be_nil
                    end
                  end

                  after(:all) { Dir.glob("#{@tmp_dir}/*") { |file| FileUtils.rm file } if @tmp_dir }
                  
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
  
        describe '#paddings' do
          let(:info) { Struct.new(:audio_streams, :duration) }
  
          subject { described_class.new([ { webm: 'input', mp4: 'input' } ], '/output/path').send(:paddings, infos) }
  
          context 'with empty infos' do
            let(:infos) { [] }
            it { expect(subject).to eq [] }
          end
  
          context 'with one info' do
            context 'with empty audio streams' do
              let(:infos) { [ info.new([],1) ] }
              it { expect(subject).to eq [] }
            end
            context 'with present audio streams' do
              let(:infos) { [ info.new([true],1) ] }
              it { expect(subject).to eq [ [0,0] ] }
            end
          end
  
          context 'with two infos' do
            context 'with the first audio stream empty, the second empty' do
              let(:infos) { [ info.new([],1), info.new([],3) ] }
              it { expect(subject).to eq [] }
            end
            context 'with the first audio stream present, the second empty' do
              let(:infos) { [ info.new([true],1), info.new([],3) ] }
              it { expect(subject).to eq [ [0,3] ] }
            end
            context 'with the first audio stream empty, the second present' do
              let(:infos) { [ info.new([],1), info.new([true],3) ] }
              it { expect(subject).to eq [ [1,0] ] }
            end
            context 'with the first audio stream present, the second present' do
              let(:infos) { [ info.new([true],1), info.new([true],3) ] }
              it { expect(subject).to eq [ [0,0], [0,0] ] }
            end
          end
  
          context 'with three infos' do
            context 'with the first audio stream empty, the second empty, the third empty' do
              let(:infos) { [ info.new([],1), info.new([],3), info.new([],5) ] }
              it { expect(subject).to eq [] }
            end
            context 'with the first audio stream present, the second empty, the third empty' do
              let(:infos) { [ info.new([true],1), info.new([],3), info.new([],5) ] }
              it { expect(subject).to eq [ [0,8] ] }
            end
            context 'with the first audio stream empty, the second present, the third empty' do
              let(:infos) { [ info.new([],1), info.new([true],3), info.new([],5) ] }
              it { expect(subject).to eq [ [1,5] ] }
            end
            context 'with the first audio stream empty, the second empty, the third present' do
              let(:infos) { [ info.new([],1), info.new([],3), info.new([true],5) ] }
              it { expect(subject).to eq [ [4,0] ] }
            end
            context 'with the first audio stream present, the second present, the third empty' do
              let(:infos) { [ info.new([true],1), info.new([true],3), info.new([],5) ] }
              it { expect(subject).to eq [ [0,0], [0,5] ] }
            end
            context 'with the first audio stream present, the second empty, the third present' do
              let(:infos) { [ info.new([true],1), info.new([],3), info.new([true],5) ] }
              it { expect(subject).to eq [ [0,3], [0,0] ] }
            end
            context 'with the first audio stream empty, the second present, the third present' do
              let(:infos) { [ info.new([],1), info.new([true],3), info.new([true],5) ] }
              it { expect(subject).to eq [ [1,0], [0,0] ] }
            end
            context 'with the first audio stream present, the second present, the third present' do
              let(:infos) { [ info.new([true],1), info.new([true],3), info.new([true],5) ] }
              it { expect(subject).to eq [ [0,0], [0,0], [0,0] ] }
            end
          end
  
          context 'with four infos' do
            context 'with the first audio stream empty, the second present, the third present, the fourth empty' do
              let(:infos) { [ info.new([],1), info.new([true],3), info.new([true],5), info.new([],7) ] }
              it { expect(subject).to eq [ [1,0], [0,7] ] }
            end
            context 'with the first audio stream present, the second empty, the third empty, the fourth present' do
              let(:infos) { [ info.new([true],1), info.new([],3), info.new([],5), info.new([true],7) ] }
              it { expect(subject).to eq [ [0,8], [0,0] ] }
            end
          end
  
        end

        describe '#wavs_with_paddings' do
          context 'when short inputs are placed after long inputs' do

            def concat(output_dir = nil)
              @concat ||= (
                inputs = ['con verted long', 'con verted'].map{ |p| {}.tap{ |inputs| FORMATS.each{ |f| inputs[f] = MESS::SAMPLES_FOLDER.join("#{p}.#{f}").to_s } } }
                described_class.new(inputs, output_dir)
              )
            end

            let(:mp4_inputs_infos) { concat.send(:mp4_inputs).map{ |input| Info.new(input) } }
            let(:paddings)         { concat.send(:paddings, mp4_inputs_infos) }

            subject { concat.send(:wavs_with_paddings, mp4_inputs_infos, paddings) }

            before do
              Dir.mktmpdir do |output_dir|
                concat(output_dir)
                concat.send(:create_log_folder)
                concat.send(:in_tmp_dir) { subject }
              end
            end

            it 'respects the concatenations order' do
              expect(subject.keys.map{ |p| File.basename(p) }).to eq ["concat0.wav", "concat1.wav"]
            end

          end
        end
  
      end
    end
  end
end

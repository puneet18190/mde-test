require 'spec_helper'

module Media
  describe Info do

    context "when the video is not valid" do
      describe 'new' do
        subject { described_class.new(MESS::INVALID_VIDEO) }
        it { expect { subject }.to raise_error(Error) }
      end
    end

    context "when the video is valid" do
      subject { described_class.new(MESS::VALID_VIDEO) }

      it "parses video duration" do
        expect(subject.duration).to eq 38.17
      end
      it "parses video streams" do
        expect(subject.video_streams).to eq [{ codec: 'flv', width: 426, height: 240, bitrate: 200 }]
      end
      it "parses audio streams" do
        expect(subject.audio_streams).to eq [{ codec: 'adpcm_swf', bitrate: 176 }]
      end

      describe '#similar_to?' do
        it 'works' do
          other_infos = described_class.new(MESS::SAMPLES_FOLDER.join('.flv').to_s)
          expect(subject.similar_to?(other_infos.to_hash)).to be true
        end
      end
    end

  end
end

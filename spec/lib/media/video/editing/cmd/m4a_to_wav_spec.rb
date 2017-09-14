require 'spec_helper'

module Media
  module Video
    module Editing
      class Cmd
        describe M4aToWav do
          subject { described_class.new('inp ut', 'out put') }
          
          describe '#to_s' do
            it('works') { expect(subject.to_s).to eq(%Q[avconv -loglevel debug -benchmark -y -timelimit 86400 -i inp\\ ut -strict experimental -threads auto -c:a pcm_s16le -map 0:a:0 out\\ put]) }
          end
        end
      end
    end
  end
end

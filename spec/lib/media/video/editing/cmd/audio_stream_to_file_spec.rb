require 'spec_helper'

module Media
  module Video
    module Editing
      class Cmd
        describe AudioStreamToFile do
          let(:pre_command) { MESS::AVCONV_PRE_COMMAND }
          
          subject { described_class.new('inp ut', 'out put') }
          
          describe '#to_s' do
            it('works') { expect(subject.to_s).to eq(%Q[#{pre_command} -i inp\\ ut -map 0:a:0 -c copy out\\ put]) }
          end
        end
      end
    end
  end
end

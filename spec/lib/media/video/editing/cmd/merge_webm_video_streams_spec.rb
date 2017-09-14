require 'spec_helper'

module Media
  module Video
    module Editing
      class Cmd
        describe MergeWebmVideoStreams do
  
          let(:pre_command) { 'mkvmerge' }
  
          subject { described_class.new(inputs, 'out put.webm') }
          
          context 'with 2 videos' do
            let(:inputs) { [ 'concat 0.webm', 'concat 1.webm' ] }
            describe '#to_s' do
              it('works') { expect(subject.to_s).to eq("#{pre_command} -o out\\ put.webm --verbose --no-audio concat\\ 0.webm + --no-audio concat\\ 1.webm") }
            end
          end
  
        end
      end
    end
  end
end

require 'spec_helper'

module Media
  module Video
    module Editing
      class Cmd
        class Concat
          describe Webm do
            let(:pre_command) { MESS::AVCONV_PRE_COMMAND }
            
            subject { described_class.new('video input', audio_input, 10, 'out put') }
            
            context 'with audio input' do
              let(:audio_input) { 'audio input' }
              describe '#to_s' do
                it('works') { expect(subject.to_s).to eq(%Q[#{pre_command} -i video\\ input -i audio\\ input -strict experimental -sn -threads #{AVCONV_OUTPUT_THREADS[:webm]} -q:v 1 -q:a 5 -b:v 2M -c:v copy -c:a libvorbis -t 10.0 -shortest out\\ put]) }
              end
            end
  
            context 'with no audio input' do
              let(:audio_input) { nil }
              describe '#to_s' do
                it('works') { expect(subject.to_s).to eq(%Q[#{pre_command} -i video\\ input -strict experimental -sn -threads #{AVCONV_OUTPUT_THREADS[:webm]} -q:v 1 -q:a 5 -b:v 2M -c:v copy -t 10.0 -shortest out\\ put]) }
              end
            end
  
          end
        end
      end
    end
  end
end

require 'spec_helper'

module Media
  module Video
    module Editing
      class Cmd
        describe GenerateTransitionFrames do
  
          let(:pre_command) { MESS::IMAGEMAGICK_CONVERT_PRE_COMMAND }
          
          subject { described_class.new('start frame', 'end frame', 'frames format', 23) }
          
          let(:command) { "#{pre_command} start\\ frame end\\ frame -morph 23 frames\\ format" }
  
          describe '#to_s' do
            it('works') { expect(subject.to_s).to eq(command) }
          end
  
        end
      end
    end
  end
end

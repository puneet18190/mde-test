require 'spec_helper'

module Media
  module Video
    module Editing
      class Cmd
        describe Transition do
          
          let(:command) do
            pre_command = MESS::AVCONV_PRE_COMMAND
            { mp4:  "#{pre_command} -r 25 -i transition\\ format -strict experimental -sn -threads #{AVCONV_OUTPUT_THREADS[:mp4]} -q:v 1 -c:v libx264 output",
              webm: "#{pre_command} -r 25 -i transition\\ format -strict experimental -sn -threads #{AVCONV_OUTPUT_THREADS[:webm]} -q:v 1 -b:v 2M -c:v libvpx output" }
          end
          
          MESS::VIDEO_FORMATS.each do |format|
  
            context "with #{format} format", format: format do
              let(:format) { format }
            
              subject { described_class.new('transition format', 'output', 25, format) }
  
              describe '#to_s' do
                it('works') { expect(subject.to_s).to eq(command[format]) }
              end
            end
  
          end
        end
      end
    end
  end
end

require 'spec_helper'

module Media
  module Video
    module Editing
      class Cmd
        describe Crop do
  
          let(:pre_command) { MESS::AVCONV_PRE_COMMAND }
          let(:command) do
            { mp4:  "#{pre_command} -i in\\ put -strict experimental -sn -threads #{AVCONV_OUTPUT_THREADS[:mp4]} -q:v 1 -q:a 4 -c:v libx264 -c:a aac -ss 10.0 -t 20.0 out\\ put",
              webm: "#{pre_command} -i in\\ put -strict experimental -sn -threads #{AVCONV_OUTPUT_THREADS[:webm]} -q:v 1 -q:a 5 -b:v 2M -c:v libvpx -c:a libvorbis -ss 10.0 -t 20.0 out\\ put" }
          end
          
          MESS::VIDEO_FORMATS.each do |format|
  
            context "with #{format} format", format: format do
              let(:format) { format }
            
              subject { described_class.new('in put', 'out put', 10, 20, format) }
  
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

require 'spec_helper'

module Media
  module Video
    module Editing
      class Cmd
        describe ReplaceAudio do
          
          let(:command) do
            pre_command = MESS::AVCONV_PRE_COMMAND
            { mp4:  "#{pre_command} -i video\\ input -i audio\\ input -strict experimental -sn -threads #{AVCONV_OUTPUT_THREADS[:mp4]} -q:v 1 -map 0:v:0 -map 1:a:0 -c:v copy -c:a copy -t 45.67 out\\ put",
              webm: "#{pre_command} -i video\\ input -i audio\\ input -strict experimental -sn -threads #{AVCONV_OUTPUT_THREADS[:webm]} -q:v 1 -q:a 5 -b:v 2M -map 0:v:0 -map 1:a:0 -c:v copy -c:a libvorbis -q:a 5 -t 45.67 out\\ put" }
          end
          
          MESS::VIDEO_FORMATS.each do |format|
  
            context "with #{format} format", format: format do
              let(:format) { format }
            
              subject { described_class.new('video input', 'audio input', 45.67, 'out put', format) }
  
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

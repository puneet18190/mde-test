require 'spec_helper'

module Media
  module Video
    module Editing
      class Cmd
        describe ExtractFrame do
  
          let(:pre_command) { MESS::AVCONV_PRE_COMMAND }
          let(:commands) { { mp4:  "#{pre_command} -i inp\\ ut -strict experimental -ss 10 -frames:v 1 out\\ put",
                             webm: "#{pre_command} -i inp\\ ut -strict experimental -ss 10 -frames:v 1 out\\ put" } }
          
          subject { described_class.new('inp ut', 'out put', 10) }
          
          MESS::VIDEO_FORMATS.each do |format|
            context "with #{format} format", format: format do
              let!(:format)  { format }
              let!(:command) { commands[format] }
  
              describe '#to_s' do
                it('works') { expect(subject.to_s).to eq(command) }
              end
            end
          end
  
        end
      end
    end
  end
end

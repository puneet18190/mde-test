require 'spec_helper'

module Media
  module Video
    module Editing
      class Cmd
        describe ImageToVideo do
          
          supported_formats = FORMATS
  
          let(:pre_command) { MESS::AVCONV_PRE_COMMAND }
          let(:vbitrate) { MESS::VBITRATE }
  
          supported_formats.each do |format|
            context "with #{format} format", format: format do
  
            subject { described_class.new('in put', 'out put', format, 123.456) }
  
            describe '#to_s' do
              it('works') { expect(subject.to_s).to eq("#{pre_command} -loop 1 -i in\\ put -strict experimental -sn -threads #{AVCONV_OUTPUT_THREADS[format]} -q:v 1#{vbitrate[format]} -c:v #{AVCONV_CODECS[format][0]} -t 123.46 out\\ put") }
            end
            end
          end
          
        end
      end
    end
  end
end

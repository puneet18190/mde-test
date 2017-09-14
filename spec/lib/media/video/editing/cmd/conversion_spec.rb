require 'spec_helper'

module Media
  module Video
    module Editing
      class Cmd
        describe Conversion do
  
          let(:subexec_options) { MESS::AVCONV_SUBEXEC_OPTIONS }
          let(:pre_command)     { MESS::AVCONV_PRE_COMMAND }
        
          supported_formats = FORMATS
  
          describe 'class methods' do
            subject { described_class }
  
            describe '#subexec_options' do
              it('works') { expect(subject.subexec_options).to eq(subexec_options) }
            end
  
            describe 'new' do
              context 'with unsupported formats' do
                subject { described_class.new('in\ put', 'out\ put', :unsupported_format, double(video_streams: [], audio_streams: [])) }
                it { expect { subject }.to raise_error(Error) }
              end
  
              supported_formats.each do |format|
  
                context "with format #{format}" do
                  context 'without any video stream' do
                    subject { described_class.new('in\ put', 'out\ put', format, double(video_streams: [], audio_streams: [])) }
                    it { expect { subject }.to raise_error(Error) }
                  end
                end
  
              end
            end
  
          end
  
          describe 'streams' do
  
            supported_formats.each do |format|
  
              context "with format #{format}" do
                
                let(:ow)             { AVCONV_OUTPUT_WIDTH        }
                let(:oh)             { AVCONV_OUTPUT_HEIGHT       }
                let(:oar)            { AVCONV_OUTPUT_ASPECT_RATIO }
                let!(:format)        { format }
                let!(:vbitrate) { ' -b:v 2M' if format == :webm }
                let!(:cmd_format)   do
                  %Q[#{pre_command} -i inp\\ ut -strict experimental -sn -threads #{AVCONV_OUTPUT_THREADS[format]} -q:v 1 -q:a #{AVCONV_OUTPUT_QA[format]}#{vbitrate} -c:v #{AVCONV_CODECS[format][0]} -c:a #{AVCONV_CODECS[format][1]} -map 0:v:0%s -vf 'scale=lt(iw/ih\\,#{oar})*#{ow}+gte(iw/ih\\,#{oar})*-1:lt(iw/ih\\,#{oar})*-1+gte(iw/ih\\,#{oar})*#{oh},crop=#{ow}:#{oh}:(iw-ow)/2:(ih-oh)/2' -ac 2 -ar 44100 out\\ put]
                end
  
                context 'when audio streams are not present' do
                  context 'when the first video stream' do
                    context 'has a bitrate' do
                      let(:input_file_info) { double(video_streams: [ { bitrate: 100 }, { bitrate: 'ignored' } ], audio_streams: []) }
                      subject { described_class.new('inp ut', 'out put', format, input_file_info) }
                      describe '#to_s' do
                        it('works') { expect(subject.to_s).to eq(cmd_format % '') }
                      end
                    end
  
                    context 'has not a bitrate' do
                      let(:input_file_info) { double(video_streams: [ { bitrate: nil }, { bitrate: 'ignored' } ], audio_streams: []) }
                      subject { described_class.new('inp ut', 'out put', format, input_file_info ) }
                      describe '#to_s' do
                        it('works') { expect(subject.to_s).to eq(cmd_format % '') }
                      end
                    end
                  end
                end
  
                context 'when there is at least one audio stream and the first audio stream' do
                  context 'has a bitrate' do
                    context 'when the first video stream' do
                      context 'has a bitrate' do
                        let(:input_file_info) { double(video_streams: [ { bitrate: 100 }, { bitrate: 'ignored' } ], audio_streams: [ { bitrate: 50 }, { bitrate: 'ignored' } ]) }
                        subject { described_class.new('inp ut', 'out put', format, input_file_info) }
                        describe '#to_s' do
                          it('works') { expect(subject.to_s).to eq(cmd_format % ' -map 0:a:0') }
                        end
                      end
  
                      context 'has not a bitrate' do
                        let(:input_file_info) { double(video_streams: [ { bitrate: nil }, { bitrate: 'ignored' } ], audio_streams: [ { bitrate: 50 }, { bitrate: 'ignored' } ]) }
                        subject { described_class.new('inp ut', 'out put', format, input_file_info ) }
                        describe '#to_s' do
                          it('works') { expect(subject.to_s).to eq(cmd_format % ' -map 0:a:0') }
                        end
                      end
                    end
                  end
  
                end
  
              end
            end
  
          end
  
        end
  
      end
    end
  end
end

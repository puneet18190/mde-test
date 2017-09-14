require 'spec_helper'

module Media
  module Audio
    module Editing
      class Cmd
        describe Concat do

          let(:pre_command) { 'sox -V6 --buffer 131072 --multi-threaded' }
          let(:output)      { 'out put.wav' }
          let(:format)      { nil }
  
          context 'with a Sox supported format' do

            subject { described_class.new(audios_with_paddings, output, format) }
            
            context 'with 1 audio' do
              let(:audios_with_paddings) { [ ['concat 0.wav', [1.234, 5.678] ] ] }
              describe '#to_s' do
                it('works') { expect(subject.to_s).to eq("#{pre_command} concat\\ 0.wav out\\ put.wav pad 1.23 5.68") }
              end
              context 'with empty paddings' do
                let(:audios_with_paddings) { [ ['concat 0.wav', [0, 0.0] ] ] }
                describe '#to_s' do
                  it('works') { expect(subject.to_s).to eq("#{pre_command} concat\\ 0.wav out\\ put.wav") }
                end
              end
            end
    
            context 'with 2 audios' do
              let(:audios_with_paddings) { [ ['concat 0.wav', [1.234, 5.678] ], ['concat 1.wav', [8.765, 4.321] ] ] }
              describe '#to_s' do
                it('works') { expect(subject.to_s).to eq("#{pre_command} concat\\ 0.wav -p pad 1.23 5.68 | #{pre_command} -p concat\\ 1.wav out\\ put.wav pad 8.77 4.32") }
              end
            end
    
            context 'with 3 audios' do
              let(:audios_with_paddings) { [ ['concat 0.wav', [1.234, 5.678] ], ['concat 1.wav', [8.765, 4.321] ], ['concat 3.wav', [12.34, 56.78] ] ] }
              describe '#to_s' do
                it('works') { expect(subject.to_s).to eq("#{pre_command} concat\\ 0.wav -p pad 1.23 5.68 | #{pre_command} -p concat\\ 1.wav -p pad 8.77 4.32 | #{pre_command} -p concat\\ 3.wav out\\ put.wav pad 12.34 56.78") }
              end
            end
          end

          context 'with a Sox unsupported format' do
            let(:output) { 'out put.m4a' }
            let(:format) { :m4a }

            subject { described_class.new(audios_with_paddings, output, format) }

            context 'with 1 audio' do
              let(:audios_with_paddings) { [ ['concat 0.m4a', [1.234, 5.678] ] ] }
              describe '#to_s' do
                it('works') { expect(subject.to_s).to eq("( ( avconv -i concat\\ 0.m4a -f sox - | pad 1.23 5.68 ) ) | sox -p -p | avconv -f sox -i - -strict experimental -c:a aac out\\ put.m4a") }
              end
              context 'with empty paddings' do
                let(:audios_with_paddings) { [ ['concat 0.m4a', [0, 0.0] ] ] }
                describe '#to_s' do
                  it('works') { expect(subject.to_s).to eq("( ( avconv -i concat\\ 0.m4a -f sox - ) ) | sox -p -p | avconv -f sox -i - -strict experimental -c:a aac out\\ put.m4a") }
                end
              end
            end
          
            context 'with 2 audios' do
              let(:audios_with_paddings) { [ ['concat 0.m4a', [1.234, 5.678] ], ['concat 1.m4a', [8.765, 4.321] ] ] }
              describe '#to_s' do
                it('works') { expect(subject.to_s).to eq("( ( avconv -i concat\\ 0.m4a -f sox - | pad 1.23 5.68 ) ; ( avconv -i concat\\ 1.m4a -f sox - | pad 8.77 4.32 ) ) | sox -p -p | avconv -f sox -i - -strict experimental -c:a aac out\\ put.m4a") }
              end
            end
          
            context 'with 3 audios' do
              let(:audios_with_paddings) { [ ['concat 0.m4a', [1.234, 5.678] ], ['concat 1.m4a', [8.765, 4.321] ], ['concat 3.m4a', [12.34, 56.78] ] ] }
              describe '#to_s' do
                it('works') { expect(subject.to_s).to eq("( ( avconv -i concat\\ 0.m4a -f sox - | pad 1.23 5.68 ) ; ( avconv -i concat\\ 1.m4a -f sox - | pad 8.77 4.32 ) ; ( avconv -i concat\\ 3.m4a -f sox - | pad 12.34 56.78 ) ) | sox -p -p | avconv -f sox -i - -strict experimental -c:a aac out\\ put.m4a") }
              end
            end
          end
  
        end
      end
    end
  end
end

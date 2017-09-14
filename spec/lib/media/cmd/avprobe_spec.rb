require 'spec_helper'

module Media
  class Cmd
    describe Avprobe do

      describe 'class methods' do
        let(:subexec_options) { MESS::AVPROBE_SUBEXEC_OPTIONS }
        subject { described_class }

        describe '#subexec_options' do
          it('works') { expect(subject.subexec_options).to eq(subexec_options) }
        end
      end

      let(:input) { 'in put.flv' }
      subject { described_class.new(input) }

      describe '#to_s' do
        it('works') { expect(subject.to_s).to eq("#{MESS::AVPROBE_PRE_COMMAND} in\\ put.flv") }
      end

      describe 'run' do
        it 'returns a Subexec instance' do
          expect(subject.run).to be_an_instance_of Subexec
        end
        it 'sets #subexec to the same object returned by the method' do
          expect(subject.run).to be subject.subexec
        end
        it 'sets the correct #subexec sh vars' do
          expect(subject.run.sh_vars).to eq MESS::AVPROBE_SUBEXEC_SH_VARS
        end
        it 'sets the correct #subexec timeout' do
          expect(subject.run.timeout).to eq MESS::AVPROBE_SUBEXEC_TIMEOUT
        end
        it 'sets #exitstatus equal to subexec exitstatus' do
          expect(subject.run.exitstatus).to be subject.exitstatus
        end
        context 'with a valid video' do
          let(:input) { MESS::VALID_VIDEO }
          it 'sets exitstatus equal to 0' do
            expect(subject.run.exitstatus).to be 0
          end
        end
        context 'with an invalid video' do
          let(:input) { MESS::INVALID_VIDEO }
          it 'sets exitstatus greater than 0' do
            expect(subject.run.exitstatus).to be > 0
          end
        end
      end
    end
  end
end

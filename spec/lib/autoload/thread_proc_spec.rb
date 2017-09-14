require 'spec_helper'

describe ThreadProc do
  describe '.new' do

    context 'when initialized with a block' do

      subject { described_class.new {} }

      let(:raw_sources) do
        { close_connection_before_execution_true:
            "proc do\n        CLOSE_CONNECTION_PROC.call\n        block.call\n      end",
          close_connection_before_execution_false:
            "proc do\n        begin\n          block.call\n        ensure\n          CLOSE_CONNECTION_PROC.call\n        end\n      end"
        }
      end
      
      it "returns a #{described_class} instance" do
        expect(subject.class).to eq described_class
      end

      context 'when "close_connection_before_execution" option is true' do

        subject { described_class.new(close_connection_before_execution: true) {} }

        it 'calls CLOSE_CONNECTION_PROC before executing the passed block' do
          expect(subject.to_raw_source).to eq raw_sources[:close_connection_before_execution_true]
        end
      end

      context 'when "close_connection_before_execution" option is false' do

        subject { described_class.new(close_connection_before_execution: false) {} }

        it 'calls CLOSE_CONNECTION_PROC after executing the passed block' do
          expect(subject.to_raw_source).to eq raw_sources[:close_connection_before_execution_false]
        end
      end

      context 'when "close_connection_before_execution" is not passed' do

        subject { described_class.new {} }

        it 'behaves like if "close_connection_before_execution" was false' do
          expect(subject.to_raw_source).to eq raw_sources[:close_connection_before_execution_false]
        end
      end

      context 'when the initializing block is a ThreadProc' do

        let(:initializing_block) { ThreadProc.new {} }
        subject { described_class.new &initializing_block }

        it 'returns it' do
          expect(subject).to be initializing_block
        end
      end

    end

    context 'when initialized without block' do

      subject { described_class.new }

      it { expect { subject }.to raise_error ArgumentError, 'tried to create Proc object without a block' }
    end

  end
end

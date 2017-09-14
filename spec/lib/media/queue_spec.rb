require 'spec_helper'

require 'user'

module Media
  describe Queue do
    describe '.run' do
      it 'works' do
        expect{ described_class.run(*Array.new(described_class::DATABASE_POOL+5){ proc{ User.first } }) }.to_not raise_error
        expect{ described_class.run(*Array.new(described_class::DATABASE_POOL+5){ proc{ User.first } }) }.to_not raise_error
      end
    end
  end
end

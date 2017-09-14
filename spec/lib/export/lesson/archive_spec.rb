require 'spec_helper'

require 'export'
require 'export/lesson/archive/assets'

require 'lesson'

module Export
  module Lesson
    describe Archive do
      it 'works' do
        described_class::Assets.remove_folder!
        described_class::Assets.compile
        described_class.remove_folder!
        expect{ described_class.new(::Lesson.first, '').find_or_create.output_path }.to_not raise_error
      end
    end
  end
end
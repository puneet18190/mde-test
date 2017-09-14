require 'spec_helper'

require 'export'
require 'export/lesson/archive/assets'

require 'lesson'

module Export
  module Lesson
    class Archive
      describe Assets do
        it 'works' do
          described_class.remove_folder!
          expect{ described_class.compile }.to_not raise_error
        end
      end
    end
  end
end
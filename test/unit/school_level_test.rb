require 'test_helper'

class SchoolLevelTest < ActiveSupport::TestCase
  
  def setup
    @school_level = SchoolLevel.new :description => 'Scuola Primaria'
  end
  
  test 'empty_and_defaults' do
    @school_level = SchoolLevel.new
    assert_error_size 1, @school_level
  end
  
  test 'types' do
    assert_invalid @school_level, :description, long_string(256), long_string(255), :too_long, {:count => 255}
    assert_obj_saved @school_level
  end
  
  test 'association_methods' do
    assert_nothing_raised {@school_level.users}
    assert_nothing_raised {@school_level.lessons}
  end
  
end

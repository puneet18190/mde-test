require 'test_helper'

class SubjectTest < ActiveSupport::TestCase
  
  def setup
    @subject = Subject.new :description => 'Scuola Primaria'
  end
  
  test 'empty_and_defaults' do
    @subject = Subject.new
    assert_error_size 1, @subject
  end
  
  test 'types' do
    assert_invalid @subject, :description, long_string(256), long_string(255), :too_long, {:count => 255}
    assert_obj_saved @subject
  end
  
  test 'association_methods' do
    assert_nothing_raised {@subject.users_subjects}
    assert_nothing_raised {@subject.lessons}
  end
  
end

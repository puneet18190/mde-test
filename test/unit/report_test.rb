require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  
  def setup
    @report = Report.new
    @report.user_id = 1
    @report.reportable_type = 'Lesson'
    @report.reportable_id = 1
    @report.comment = "Non sono d'accordo con il contenuto"
  end
  
  test 'empty_and_defaults' do
    @report = Report.new
    assert_error_size 7, @report
  end
  
  test 'types' do
    assert_invalid @report, :user_id, 'ehi', 1, :not_a_number
    assert_invalid @report, :reportable_id, 5.66, 1, :not_an_integer
    assert_invalid @report, :user_id, -4, 1, :greater_than, {:count => 0}
    assert_invalid @report, :reportable_type, 'Lazie', 'Lesson', :inclusion
    assert_obj_saved @report
  end
  
  test 'uniqueness' do
    assert_invalid @report, :reportable_id, 2, 1, :taken
    @report.reportable_type = 'MediaElement'
    assert_invalid @report, :reportable_id, 1, 5, :taken
    # I prove that it is possible to report items not public and mine
    assert_equal 'MediaElement', @report.reportable_type
    my_reportable = MediaElement.find(@report.reportable_id)
    assert_equal @report.user_id, my_reportable.user_id
    assert !my_reportable.is_public
    assert_obj_saved @report
  end
  
  test 'associations' do
    assert_invalid @report, :user_id, 1000, 1, :doesnt_exist
    assert_invalid @report, :reportable_id, 1000, 1, :lesson_doesnt_exist
    @report.reportable_type = 'MediaElement'
    assert_invalid @report, :reportable_id, 1000, 2, :media_element_doesnt_exist
    assert_obj_saved @report
  end
  
  test 'association_methods' do
    assert_nothing_raised {@report.user}
    assert_nothing_raised {@report.reportable}
  end
  
  test 'impossible_changes' do
    assert_obj_saved @report
    assert_invalid @report, :user_id, 2, 1, :cant_be_changed
    assert_invalid @report, :reportable_id, 2, 1, :cant_be_changed
    Report.where(:reportable_type => 'MediaElement', :reportable_id => 1, :user_id => 1).first.destroy
    assert_invalid @report, :reportable_type, 'MediaElement', 'Lesson', :cant_be_changed
    assert_invalid @report, :comment, "Non ho d'accordo con il contenuto", "Non sono d'accordo con il contenuto", :cant_be_changed
    assert_obj_saved @report
  end
  
end

# ### Description
#
# Contains the actions necessary to send a report of inappropriate content
#
# ### Models used
#
# * Report
#
class ReportsController < ApplicationController
  
  # ### Description
  #
  # Reports a lesson
  #
  # ### Mode
  #
  # Ajax
  #
  def lesson
    if correct_integer?(params[:lesson_id])
      @lesson_id = params[:lesson_id].to_i
      @resp = current_user.report_lesson(@lesson_id, params[:content])
      @error = current_user.get_base_error
    else
      @lesson_id = nil
      @resp = false
      @error = I18n.t('activerecord.errors.models.user.problem_reporting')
    end
  end
  
  # ### Description
  #
  # Reports an element
  #
  # ### Mode
  #
  # Ajax
  #
  def media_element
    if correct_integer?(params[:media_element_id])
      @media_element_id = params[:media_element_id].to_i
      @resp = current_user.report_media_element(@media_element_id, params[:content])
      @error = current_user.get_base_error
    else
      @media_element_id = nil
      @resp = false
      @error = I18n.t('activerecord.errors.models.user.problem_reporting')
    end
  end
  
end

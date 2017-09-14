# ### Description
#
# Controller for the actions related to reports in the administration (see AdminController). Actions in this controller may be called by Admin::DashboardController and Admin::MessagesController
#
# ### Models used
#
# * Report
#
class Admin::ReportsController < AdminController
  
  layout 'admin'
  
  # ### Description
  #
  # A report is accepted and thus the associated lesson or element is deleted, together with the report
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  #
  def accept
    @ok = correct_integer? params[:id]
    if @ok
      @report = Report.find_by_id params[:id]
      @report.accept if @report
    end
  end
  
  # ### Description
  #
  # A report is declined and thus the associated lesson or element is *not* deleted; the report itself is deleted, instead
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * ApplicationController#admin_authenticate
  #
  def decline
    @ok = correct_integer? params[:id]
    if @ok
      @report = Report.find_by_id params[:id]
      @report.decline if @report
    end
  end
  
end

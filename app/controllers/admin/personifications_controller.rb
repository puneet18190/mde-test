class Admin::PersonificationsController < AdminController

  skip_before_filter :admin_authenticate

  def create
    unless current_user.super_admin?
      unauthorized
      return
    end

    self.personificated_user = User.confirmed.find_by_id params[:id]
    redirect_to dashboard_path
  end

  def destroy
    unless current_user!.try :super_admin?
      unauthorized
      return
    end

    self.personificated_user = nil
    self.current_user = current_user!

    redirect_to admin_root_path
  end

end

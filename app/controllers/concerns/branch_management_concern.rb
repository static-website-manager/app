module BranchManagementConcern
  extend ActiveSupport::Concern

  included do
    # Set the current website’s branch and save its name in the session.
    before_action do
      branch_param = controller_name == 'branches' ? params[:id] : params[:branch_id]
      @branch = @website.branch(branch_param == 'working' ? current_user : branch_param)
      session[:branch_name] = @branch.name
    end
  end
end

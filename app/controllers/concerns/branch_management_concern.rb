module BranchManagementConcern
  extend ActiveSupport::Concern

  included do
    # Set the current branch.
    before_action do
      @branch = @website.branch(branch_id)
    end
  end

  private

  # Pass along the current user as a proxy for the "working" branch.
  def branch_id
    branch_param == 'working' ? current_user : branch_param
  end

  def branch_param
    controller_name == 'branches' ? params[:id] : params[:branch_id]
  end
end

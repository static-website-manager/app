module BranchManagementConcern
  extend ActiveSupport::Concern

  included do
    before_action do
      @branch = @website.branch(branch_id)
    end
  end

  private

  def branch_id
    branch_param == 'working' ? "user_#{current_user.id}" : branch_param
  end

  def branch_param
    controller_name == 'branches' ? params[:id] : params[:branch_id]
  end
end

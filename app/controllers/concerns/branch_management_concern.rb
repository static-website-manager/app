module BranchManagementConcern
  extend ActiveSupport::Concern

  included do
    before_action :require_user

    before_action do
      @branch = @website.repository.branches.find(branch_id)
    end
  end

  private

  def branch_id
    controller_name == 'branches' ? params[:id] : params[:branch_id]
  end
end

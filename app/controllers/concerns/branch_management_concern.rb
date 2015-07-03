module BranchManagementConcern
  extend ActiveSupport::Concern

  included do
    # Set the current repository’s branch, commit, and tree.
    before_action do
      branch_param = controller_name == 'branches' ? params[:id] : params[:branch_id]
      @branch = @repository.branch(branch_param == 'working' ? current_user : branch_param)
      @commit = @branch.commit
      @tree = @commit.tree
      session[:branch_name] = @branch.name
    end
  end
end

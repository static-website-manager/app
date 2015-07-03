module BranchManagementConcern
  extend ActiveSupport::Concern

  included do
    # Set the current repository’s branch, commit, and tree.
    before_action do
      branch_param = controller_name == 'branches' ? params[:id] : params[:branch_id]
      session[:branch_name] = branch_param == 'working' ? current_user : branch_param
      @branch = @repository.branch(session[:branch_name])
      @commit = @branch.commit
      @tree = @commit.tree
    end
  end
end

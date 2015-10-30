class SetupsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :set_return_to

  before_action do
    if @repository.setup?
      redirect_to [@website, @repository.branch(current_user)]
    end
  end

  def show
    if current_authorization.account_owner?
      @team_members = @website.users.where.not(id: current_user.id)
    end

    if current_authorization.ssh_access?
      @authentication = current_user.authentication || current_user.build_authentication
    end
  end
end

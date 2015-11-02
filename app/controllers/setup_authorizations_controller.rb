class SetupAuthorizationsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_account_owner

  before_action do
    if @repository.setup?
      redirect_to [@website, @repository.branch(current_user)]
    end
  end

  before_action do
    @authorization = @website.authorizations.new
    @authorization.build_user
  end

  def create
    @authorization.assign_attributes(authorization_params)
    @authorization.content_role = :designer
    @authorization.ssh_access = true
    @authorization.production_branch_access = true
    @authorization.staging_branch_access = true
    @authorization.custom_branch_access = true

    if existing_user = User.find_by_email(@authorization.user.email)
      @authorization.user = existing_user
    end

    if @authorization.save
      UserMailer.authorization_invitation(@authorization).deliver_later
      redirect_to [@website, :setup], notice: t('.notice_html', email: @authorization.user.email)
    else
      flash.now.alert = 'There was a problem inviting your team member.'
      render :new, status: 422
    end
  end

  private

  def authorization_params
    params.require(:authorization).permit(
      :account_owner,
      user_attributes: [
        :email,
        :name,
      ],
    )
  end
end

class AuthorizationsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_account_owner

  before_action only: %i[new create] do
    if @website.authorizations.count >= @website.allowed_users
      redirect_to [@website, :authorizations], alert: t('.alert_exceeded')
    end
  end

  # Initialize a new authorization with user.
  before_action only: %i[new create] do
    @authorization = @website.authorizations.new
    @authorization.build_user
  end

  # Set the authorization.
  before_action only: %i[edit update destroy] do
    @authorization = @website.authorizations.find(params[:id])
  end

  # Prevent users from removing their own authorization.
  before_action only: %i[destroy] do
    if @authorization.user == current_user
      redirect_to [@website, :authorizations], alert: t('.alert_self')
    end
  end

  def index
    @authorizations = @website.authorizations
  end

  def create
    @authorization.assign_attributes(authorization_user_params)

    if existing_user = User.find_by_email(@authorization.user.email)
      @authorization.user = existing_user
    end

    if @authorization.save
      if @repository.setup?
        branch = @repository.branch(@authorization.user, auto_create_staging: false) rescue nil

        if branch
          production_branch = @repository.branch('master')

          if @website.auto_rebase_staging_on_production_changes? && branch.rebase_required?(production_branch) && branch.rebase(production_branch)
            JekyllBuildJob.perform_later(@website, branch.name, branch.commit_id)
          end
        else
          branch = @repository.branch(@authorization.user)
          JekyllBuildJob.perform_later(@website, branch.name, branch.commit_id)
        end
      end
      UserMailer.authorization_invitation(@authorization).deliver_later
      redirect_to [@website, :authorizations], notice: t('.notice_html', email: @authorization.user.email)
    else
      flash.now.alert = t('.alert')
      render :new, status: 422
    end
  end

  def update
    if @authorization.update(authorization_params)
      redirect_to [@website, :authorizations], notice: t('.notice_html', email: @authorization.user.email)
    else
      flash.now.alert = t('.alert')
      render :edit, status: 422
    end
  end

  def destroy
    if @authorization.destroy
      redirect_to [@website, :authorizations], notice: t('.notice_html', email: @authorization.user.email)
    else
      redirect_to [@website, :authorizations], alert: t('.alert')
    end
  end

  private

  def authorization_params
    params.require(:authorization).permit(
      :account_owner,
      :content_role,
      :custom_branch_access,
      :production_branch_access,
      :ssh_access,
      :staging_branch_access,
    )
  end

  def authorization_user_params
    params.require(:authorization).permit(
      :account_owner,
      :content_role,
      :custom_branch_access,
      :production_branch_access,
      :ssh_access,
      :staging_branch_access,
      user_attributes: [
        :name,
        :email,
      ],
    )
  end
end

class AuthorizationsController < ApplicationController
  include WebsiteManagementConcern
  include WebsiteMasterManagementConcern

  before_action only: %i[edit update destroy] do
    @authorization = @website.authorizations.find(params[:id])
  end

  before_action only: %i[destroy] do
    if @authorization.user == current_user
      redirect_to [@website, :authorizations], alert: 'You cannot remove yourself.'
    end
  end

  def index
    @authorizations = @website.authorizations
  end

  def new
    @authorization = @website.authorizations.new
    @authorization.build_user unless @authorization.user
  end

  def create
    @authorization = @website.authorizations.new(authorization_user_params)
    @authorization.build_user unless @authorization.user

    if existing_user = User.find_by_email(@authorization.user.email)
      @authorization.user = existing_user
    else
      @authorization.user.password = @authorization.user.password_confirmation = SecureRandom.base64
    end

    if @authorization.save
      redirect_to [@website, :authorizations]
    else
      render :new, status: 422
    end
  end

  def update
    if @authorization.update(authorization_params)
      redirect_to [@website, :authorizations]
    else
      render :edit, status: 422
    end
  end

  def destroy
    if @authorization.destroy
      redirect_to [@website, :authorizations], notice: 'Ok, your team has been updated.'
    else
      redirect_to [@website, :authorizations], alert: 'There was a problem removing the team member.'
    end
  end

  private

  def authorization_params
    params.require(:authorization).permit(
      :role,
    )
  end

  def authorization_user_params
    params.require(:authorization).permit(
      :role,
      user_attributes: [
        :name,
        :email,
      ],
    )
  end
end

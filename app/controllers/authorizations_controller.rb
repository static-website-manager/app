class AuthorizationsController < ApplicationController
  include WebsiteManagementConcern

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
      redirect_to [@website, :authorizations], alert: 'You cannot remove yourself.'
    end
  end

  def index
    @authorizations = @website.authorizations
  end

  def create
    @authorization.assign_attributes(authorization_user_params)

    if existing_user = User.find_by_email(@authorization.user.email)
      @authorization.user = existing_user
    else
      @authorization.user.password = @authorization.user.password_confirmation = SecureRandom.base64
    end

    if @authorization.save
      redirect_to [@website, :authorizations], notice: "<strong>#{@authorization.user.email}</strong> has been invited to join the team!"
    else
      flash.now.alert = 'There was a problem sending the invite.'
      render :new, status: 422
    end
  end

  def update
    if @authorization.update(authorization_params)
      redirect_to [@website, :authorizations], notice: "<strong>#{@authorization.user.email}</strong>’s permissions were successfully updated."
    else
      flash.now.alert = 'There was a problem updating the team member’s permissions.'
      render :edit, status: 422
    end
  end

  def destroy
    if @authorization.destroy
      redirect_to [@website, :authorizations], notice: "#{@authorization.user.email} has been removed from the team."
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

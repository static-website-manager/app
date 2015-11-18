class SettingsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_account_owner
  before_action :require_repository

  def update
    if @website.update(settings_params)
      redirect_to [:edit, @website, :settings], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :edit, status: 422
    end
  end

  private

  def settings_params
    params.require(:website).permit(
      :name,
    )
  end
end

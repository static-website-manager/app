class SettingsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository

  def update
    if @website.update(settings_params)
      redirect_to session[:return_to] || @website, notice: 'Settings updated successfully.'
    else
      flash.now.alert = 'There was a problem saving your business settings.'
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

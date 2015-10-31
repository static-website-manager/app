class SettingsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_account_owner
  before_action :require_repository

  def update
    if @website.update(settings_params)
      redirect_to session[:return_to] || @website, notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :edit, status: 422
    end
  end

  private

  def settings_params
    params.require(:website).permit(
      :auto_create_production_deployment,
      :auto_create_staging_deployment,
      :auto_rebase_staging_on_production_changes,
      :name,
    )
  end
end

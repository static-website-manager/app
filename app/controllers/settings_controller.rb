class SettingsController < ApplicationController
  include WebsiteManagementConcern
  include WebsiteMasterManagementConcern

  def update
    if @website.update(settings_params)
      redirect_to [:edit, @website, :settings]
    else
      render :edit, status: 422
    end
  end

  private

  def settings_params
    params.require(:website).permit(
    )
  end
end

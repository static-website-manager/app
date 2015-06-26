class SettingsController < ApplicationController
  include WebsiteManagementConcern
  include WebsiteMasterManagementConcern

  def update
    if @website.update(settings_params)
      redirect_to [@website, @website.branch(current_user)]
    else
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

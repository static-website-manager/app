class SettingsController < ApplicationController
  include WebsiteManagementConcern

  def update
    if @website.update(settings_params)
      redirect_to [@website, @repository.branch(current_user)], notice: 'Settings updated successfully.'
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

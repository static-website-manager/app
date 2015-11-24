class BranchSettingsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_account_owner
  before_action :require_repository

  def update
    if @website.update(branch_settings_params)
      redirect_to [:edit, @website, :branch_settings], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :edit, status: 422
    end
  end

  private

  def branch_settings_params
    params.require(:website).permit(
      :auto_rebase_staging_on_production_changes,
    )
  end
end

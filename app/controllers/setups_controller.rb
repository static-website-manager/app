class SetupsController < ApplicationController
  include WebsiteManagementConcern

  before_action do
    if @website.repository.setup?
      redirect_to [@website, @website.branch(current_user)]
    end
  end

  def update
    if @website.update(setups_params)
      redirect_to [:edit, @website, :setup]
    else
      render :edit, status: 422
    end
  end

  private

  def setups_params
    params.require(:website).permit(
    )
  end
end

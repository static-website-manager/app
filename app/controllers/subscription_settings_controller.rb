class SubscriptionSettingsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_account_owner
  before_action :require_repository

  def update
    if @website.update(subscription_params)
      UserMailer.subscription_update_confirmation(@website).deliver_later
      redirect_to [:edit, @website, :subscription_settings], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :edit, status: 422
    end
  end

  private

  def subscription_params
    params.require(:website).permit(
      :subscription_plan,
      :yearly_billing,
    )
  end
end

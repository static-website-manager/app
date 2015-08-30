class SubscriptionsController < ApplicationController
  before_action :require_guest

  before_action only: %i[new create] do
    @subscription = Subscription.new
  end

  def create
    if @subscription.save(subscription_params)
      session[:user_id] = @subscription.user.id
      redirect_to [:new, @subscription.website, :setup], notice: 'Welcome to Static Website Manager!'
    else
      flash.now.alert = 'There was a problem subscribing your account.'
      render :new, status: 422
    end
  end

  private

  def subscription_params
    params.require(:subscription).permit(
      user_attributes: [
        :name,
        :email,
        :password,
        :password_confirmation,
      ],
      website_attributes: [
        :name,
      ],
    )
  end
end

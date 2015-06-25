class SubscriptionsController < ApplicationController
  before_action :require_guest

  def new
    @subscription = Subscription.new
  end

  def create
    @subscription = Subscription.new(subscription_params)

    if @subscription.save
      session[:user_id] = @subscription.user.id
      redirect_to [:edit, @subscription.website, :setup], notice: 'Welcome to Static Website Manager!'
    else
      flash.now.alert = 'There was a problem subscribing your account.'
      render :new
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

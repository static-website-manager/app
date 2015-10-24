class SubscriptionsController < ApplicationController
  before_action do
    if current_user
      redirect_to :new_website
    end
  end

  def new
    @subscription = Subscription.new
  end

  def create
    @subscription = Subscription.new(subscription_params)

    if @subscription.save
      sign_in(@subscription.user)
      UserMailer.subscription_confirmation(@subscription.user).deliver_later
      redirect_to [:new, @subscription.website, :setup], notice: 'Welcome to Static Website Manager!'
    else
      flash.now.alert = 'There was a problem subscribing your account.'
      render :new, status: 422
    end
  end

  private

  def subscription_params
    params.require(:subscription).permit(
      authorization_attributes: [
        :content_role,
      ],
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

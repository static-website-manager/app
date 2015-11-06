class SubscriptionsController < ApplicationController
  before_action do
    if current_user
      redirect_to :new_website
    end
  end

  before_action only: :create do
    unless params[:code] == ENV['INVITATION_CODE']
      redirect_to :new_subscription, alert: t('.alert_not_invited')
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
      redirect_to [@subscription.website, :setup], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
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

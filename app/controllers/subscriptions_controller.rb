class SubscriptionsController < ApplicationController
  before_action do
    if current_user
      redirect_to [:new_website, plan: params[:plan]]
    end
  end

  before_action do
    if Website.requires_waiting_list?
      redirect_to :new_waiting_list
    end
  end

  def new
    @subscription = Subscription.new
  end

  def create
    @subscription = Subscription.new(subscription_params)

    if params[:agree_to_terms] != '1'
      flash.now.alert = t('.alert_disagree')
      render :new, status: 422
    elsif @subscription.save
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
      :payment_information,
      user_attributes: [
        :name,
        :email,
        :password,
        :password_confirmation,
      ],
      website_attributes: [
        :name,
        :yearly_billing,
      ],
    )
  end
end

class WebsitesController < ApplicationController
  before_action :require_user
  before_action :require_website, only: %i[show]
  before_action :require_repository, only: %i[show]
  before_action :set_return_to, only: %i[index]

  before_action only: %i[new create] do
    if Website.requires_waiting_list?
      redirect_to :new_waiting_list
    end
  end

  def index
    @websites = current_user.websites
  end

  def new
    @subscription = Subscription.new(website_attributes: { subscription_plan: params[:plan].blank? ? 'small' : params[:plan] })
  end

  def create
    @subscription = Subscription.new(subscription_params)
    @subscription.user = current_user

    if @subscription.save
      UserMailer.subscription_confirmation(current_user).deliver_later
      redirect_to [@subscription.website, :setup], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :new, status: 422
    end
  end

  def show
    if @repository.setup?
      redirect_to [@website, @repository.branch(current_user)]
    else
      redirect_to [@website, :setup]
    end
  end

  private

  def subscription_params
    params.require(:subscription).permit(
      :payment_information,
      website_attributes: [
        :name,
        :subscription_plan,
        :yearly_billing,
      ],
    )
  end
end

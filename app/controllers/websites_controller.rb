class WebsitesController < ApplicationController
  before_action :require_user
  before_action :require_website, only: %i[show]
  before_action :require_repository, only: %i[show]
  before_action :set_return_to, only: %i[index]

  def index
    @websites = current_user.websites
  end

  def new
    @subscription = Subscription.new
  end

  def create
    @subscription = Subscription.new(subscription_params)
    @subscription.user = current_user

    if @subscription.save
      UserMailer.subscription_confirmation(current_user).deliver_later
      redirect_to [:new, @subscription.website, :setup], notice: 'Welcome to your new website!'
    else
      flash.now.alert = 'There was adding your website.'
      render :new, status: 422
    end
  end

  def show
    if @repository.setup?
      redirect_to [@website, @repository.branch(current_user)]
    else
      redirect_to [:new, @website, :setup]
    end
  end

  private

  def subscription_params
    params.require(:subscription).permit(
      authorization_attributes: [
        :content_role,
      ],
      website_attributes: [
        :name,
      ],
    )
  end
end

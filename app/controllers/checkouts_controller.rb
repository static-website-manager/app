class CheckoutsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_setup_repository
  before_action :require_branch

  before_action do
    @checkout = Checkout.new(user: current_user, website: @website, source: @branch.raw_name)
  end

  def create
    @checkout.target = params[:checkout].try(:[], :target)

    if @checkout.save
      redirect_to [@website, @checkout.branch], notice: 'Ok, your new branch is ready to use.'
    else
      flash.now.alert = 'There was a problem creating your branch.'
      render :new, status: 422
    end
  end
end

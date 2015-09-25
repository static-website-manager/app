class CheckoutsController < ApplicationController
  include WebsiteConcern
  include BranchConcern

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

class WaitingListsController < ApplicationController
  before_action do
    unless Website.requires_waiting_list?
      if current_user
        redirect_to :new_website
      else
        redirect_to :new_subscription
      end
    end
  end

  def new
    flash.now.alert = t('.alert')
  end
end

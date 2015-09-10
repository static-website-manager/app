class AccountsController < ApplicationController
  before_action :require_user

  def update
    if current_user.update(account_params)
      redirect_to session[:return_to] || :websites, notice: 'Your Account Information was Saved.'
    else
      flash.now.alert = 'There was a problem updating your account.'
      render :edit, status: 422
    end
  end

  private

  def account_params
    params.require(:user).permit(
      :name,
    )
  end
end

class AccountsController < ApplicationController
  before_action :require_user

  def update
    if current_user.update(account_params)
      redirect_to :edit_account, notice: t('.notice')
    else
      flash.now.alert = t('.alert')
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

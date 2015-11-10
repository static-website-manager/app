class AccountsController < ApplicationController
  before_action :require_user

  def update
    if params[:password].present? && !current_user.authenticate(params[:password])
      flash.now.alert = t('.alert_incorrect')
      render :edit, status: 422
    elsif current_user.update(account_params)
      if account_params[:password].present?
        UserMailer.password_update_confirmation(current_user).deliver_later
      end
      redirect_to session[:return_to] || :websites, notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :edit, status: 422
    end
  end

  private

  def account_params
    if params[:password].present?
      params.require(:user).permit(
        :name,
        :password,
        :password_confirmation,
        authentication_attributes: [
          :id,
          :public_key,
        ],
      )
    else
      params.require(:user).permit(
        :name,
        authentication_attributes: [
          :id,
          :public_key,
        ],
      )
    end
  end
end

class PasswordsController < ApplicationController
  skip_before_action :ensure_current_user_password, only: %i[new create]
  before_action :require_user

  before_action only: %i[new create] do
    if current_user.password_digest?
      redirect_to :websites
    end
  end

  before_action only: %i[update] do
    unless params[:password].present? && current_user.authenticate(params[:password])
      flash.now.alert = t('.alert_incorrect')
      render :edit, status: 422
    end
  end

  def create
    if current_user.update(password_params)
      UserMailer.password_update_confirmation(current_user).deliver_later
      redirect_to :websites, notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :new, status: 422
    end
  end

  def update
    if current_user.update(password_params)
      UserMailer.password_update_confirmation(current_user).deliver_later
      redirect_to :edit_account_password, notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :edit, status: 422
    end
  end

  private

  def password_params
    params.require(:user).permit(
      :password,
      :password_confirmation,
    )
  end
end

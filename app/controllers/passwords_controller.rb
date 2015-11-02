class PasswordsController < ApplicationController
  skip_before_action :ensure_current_user_password
  before_action :require_user

  before_action do
    if current_user.password_digest?
      redirect_to :websites
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

  private

  def password_params
    params.require(:user).permit(
      :password,
      :password_confirmation,
    )
  end
end

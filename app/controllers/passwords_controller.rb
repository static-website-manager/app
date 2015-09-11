class PasswordsController < ApplicationController
  before_action :require_guest

  before_action do
    @user = User.find_by_password_reset_token!(params[:token])
  end

  def update
    if @user.update(password_params)
      UserMailer.password_update_confirmation(@user).deliver_later
      sign_in(@user)
      redirect_to :websites, notice: 'Welcome back! Your password was updated successfully.'
    else
      flash.now.alert = 'There was a problem changing your password.'
      render :edit, status: 422
    end
  end

  private

  def password_params
    params.require(:user).permit(
      :password,
      :password_confirmation,
    ).merge(
      confirmed: true,
      password_reset_token: nil,
      session_token: nil,
    )
  end
end

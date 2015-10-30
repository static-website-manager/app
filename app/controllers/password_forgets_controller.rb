class PasswordForgetsController < ApplicationController
  before_action :require_guest

  def create
    user =  User.where(email: params[:email].to_s.downcase).first

    if user
      UserMailer.password_reset(user).deliver_later
      redirect_to :new_session, notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :new, status: 422
    end
  end
end

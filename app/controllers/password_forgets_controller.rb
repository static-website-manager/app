class PasswordForgetsController < ApplicationController
  before_action :require_guest

  def create
    user =  User.where(email: params[:email].to_s.downcase).first

    if user
      UserMailer.password_reset(user).deliver_later
      redirect_to :new_session, notice: 'Great! A password reset email is on the way.'
    else
      flash.now.alert = 'We could not find anyone with that email address.'
      render :new, status: 422
    end
  end
end

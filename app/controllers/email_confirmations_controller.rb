class EmailConfirmationsController < ApplicationController
  before_action :require_guest, only: %i[new create]

  def create
    user =  User.where(email: params[:email].to_s.downcase).first

    if user && user.confirmed?
      redirect_to :new_session, notice: 'You’re already confirmed — sign in now.'
    elsif user
      UserMailer.email_confirmation(user).deliver_later
      redirect_to :new_session, notice: 'Great! A confirmation email is on the way.'
    else
      flash.now.alert = 'We could not find anyone with that email address.'
      render :new, status: 422
    end
  end

  def show
    user = User.find_by_email_confirmation_token(params[:token])

    if user
      user.update_columns confirmed: true, email_confirmation_token: nil
      sign_in(user)
      redirect_to :websites, notice: 'Thanks! We‘ve confirmed your email address.'
    else
      redirect_to :new_session, alert: 'We could not verify your account.'
    end
  end
end

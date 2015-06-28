class SessionsController < ApplicationController
  before_action :require_guest, only: %i[new create]
  before_action :require_user, only: %i[destroy]

  def create
    user = User.find_by_email(params[:email])

    if user && !user.confirmed?
      @_user_confirmation_alert = true
      flash.now.alert = 'We found your account, but need you to confirm your email address first.'
      render :new
    elsif user && user.confirmed? && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to :websites, notice: 'Welcome back!'
    else
      flash.now.alert = 'We could not find anyone with those credentials.'
      render :new
    end
  end

  def destroy
    reset_session
    redirect_to :root, notice: 'Goodbye, and thanks for your business.'
  end
end

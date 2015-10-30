class SessionsController < ApplicationController
  before_action :require_guest, only: %i[new create]
  before_action :require_user, only: %i[destroy]

  def create
    user = User.find_by_email(params[:email].to_s.downcase)

    if user && !user.confirmed?
      @_user_confirmation_alert = true
      flash.now.alert = t('.alert_unconfirmed')
      render :new, status: 422
    elsif user && user.confirmed? && user.authenticate(params[:password])
      sign_in(user)
      redirect_to :websites, notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :new, status: 422
    end
  end

  def destroy
    sign_out
    redirect_to :new_session, notice: t('.notice')
  end
end

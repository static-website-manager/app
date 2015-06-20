class SessionsController < ApplicationController
  before_action :require_guest, only: %i[new create]
  before_action :require_user, only: %i[destroy]

  def create
    user = User.find_by_email(params[:email])

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to :websites
    else
      render :new
    end
  end

  def destroy
    reset_session
    redirect_to :root
  end
end

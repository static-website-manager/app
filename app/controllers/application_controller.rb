class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception

  # Set the @current_user before every request.
  before_action do
    if session[:authentication].present?
      @current_user = User.find_by_session_token(session[:authentication])
    end
  end

  # Expose the @current_user ivar to all controllers and views.
  attr_reader :current_user ; helper_method :current_user

  private

  # Before filter to ensure current users are redirected.
  def require_guest
    if current_user
      redirect_to :websites
    end
  end

  # Before filter to ensure guests are required to sign-in.
  def require_user
    unless current_user
      redirect_to :new_session
    end
  end

  # Sign in the provided user.
  def sign_in(user)
    session[:authentication] = user.session_token!
  end

  # Sign out the current user
  def sign_out
    reset_session
  end
end

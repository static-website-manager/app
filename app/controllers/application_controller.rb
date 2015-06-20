class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception

  attr_reader :current_user
  helper_method :current_user

  before_action do
    @current_user = User.find_by_id(session[:user_id])
  end

  private

  def require_guest
    if current_user
      redirect_to :websites
    end
  end

  def require_user
    unless current_user
      redirect_to :sign_in
    end
  end
end

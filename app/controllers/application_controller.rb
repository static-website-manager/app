class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception

  private

  def require_guest
    if current_user
      redirect_to :websites
    end
  end

  def require_user
    unless current_user
      redirect_to :sign_on
    end
  end
end

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception

  # Set the @current_user before every request.
  before_action do
    if session[:authentication].present?
      @current_user = User.find_by_session_token(session[:authentication])
    end
  end

  # Expose the @current_authorization and @current_user ivar to all controllers
  # and views.
  attr_reader :current_authorization, :current_user
  helper_method :current_authorization, :current_user

  private

  # Find the current website’s branch and deployment.
  def require_branch
    branch_param = controller_name == 'branches' ? params[:id] : params[:branch_id]
    @branch = @repository.branch(branch_param == 'staging' ? current_user : branch_param)

    if @branch.production? && !current_authorization.production_branch_access?
      raise ActiveRecord::RecordNotFound
    elsif @branch.staging? && @branch.user != current_user && !current_authorization.staging_branch_access?
      raise ActiveRecord::RecordNotFound
    elsif @branch.custom? && !current_authorization.custom_branch_access?
      raise ActiveRecord::RecordNotFound
    end

    @deployment = @website.deployments.find_by_branch_name(@branch.name)
  end

  # Ensure non-designers are redirected back to the website.
  def require_designer
    unless current_authorization.designer?
      redirect_to @website
    end
  end

  # Ensure non-editors and non-designers are redirected back to the website.
  def require_editor_or_designer
    unless current_authorization.editor? || current_authorization.designer?
      redirect_to @website
    end
  end

  # Ensure current users are redirected to their website list.
  def require_guest
    if current_user
      redirect_to :websites
    end
  end

  # Ensure non-account-owners are redirected back to the website.
  def require_account_owner
    unless current_authorization.account_owner?
      redirect_to session[:return_to] || @website
    end
  end

  # Find the current website’s repository.
  def require_repository
    @repository = Repository.new(website_id: @website.id)
  end

  # Ensure the current repository is setup.
  def require_setup
    unless @repository.setup?
      redirect_to [@website, :setup], alert: 'Please complete your website setup to access those features.'
    end
  end

  # Ensure guests are redirected to sign-in.
  def require_user
    unless current_user
      redirect_to :new_session
    end
  end

  # Find the current user‘s website.
  def require_website
    @current_authorization = current_user.authorizations.includes(:website).find_by_website_id!(controller_name == 'websites' ? params[:id] : params[:website_id])
    @website = @current_authorization.website
  end

  # Set the current path as a return value for nested views.
  def set_return_to
    session[:return_to] = request.path
  end

  # Sign in the provided user.
  def sign_in(user)
    @current_user = user
    session[:authentication] = user.session_token!
  end

  # Sign out the current user
  def sign_out
    reset_session
  end
end

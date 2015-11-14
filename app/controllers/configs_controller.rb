class ConfigsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_designer
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch
  before_action :set_return_to

  before_action do
    @config = @branch.config
  end

  def update
    commit_message = params[:message].present? ? params[:message] : t('.message')
    @config.config = params[:config].try(:[], :config)

    if @config.unchanged?
      redirect_to [:edit, @website, @branch, :config], alert: t('.alert_unchanged')
    elsif @config.save(current_user.email, current_user.name, commit_message)
      redirect_to [:edit, @website, @branch, :config], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :edit, status: 422
    end
  end
end

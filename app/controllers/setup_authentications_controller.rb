class SetupAuthenticationsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository

  before_action do
    if @repository.setup?
      redirect_to [@website, @repository.branch(current_user)]
    end
  end

  before_action do
    unless current_authorization.ssh_access?
      redirect_to [@website, :setup]
    end
  end

  before_action do
    @authentication = current_user.authentication || current_user.build_authentication

    if @authentication.persisted?
      redirect_to [@website, :setup]
    end
  end

  def create
    @authentication.assign_attributes(authentication_params)

    if @authentication.save
      redirect_to [@website, :setup], notice: t('.notice')
    elsif @authentication.errors[:public_key].any?
      redirect_to [@website, :setup], alert: t('.alert_ssh', errors: @authentication.errors[:public_key].to_sentence)
    else
      redirect_to [@website, :setup], alert: t('.alert')
    end
  end

  private

  def authentication_params
    params.require(:authentication).permit(
      :public_key,
    )
  end
end

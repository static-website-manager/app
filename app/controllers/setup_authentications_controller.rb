class SetupAuthenticationsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_account_owner

  before_action do
    if @repository.setup?
      redirect_to [@website, @repository.branch(current_user)]
    end
  end

  before_action do
    @authentication = current_user.authentication || current_user.build_authentication

    if @authentication.persisted?
      redirect_to [@website, :setup]
    end
  end

  def create
    begin
      ActiveRecord::Base.transaction do
        @authentication.assign_attributes(authentication_params)
        @authentication.save or raise StandardError
        current_authorization.update(ssh_access: true) or raise StandardError
      end
      redirect_to [@website, :setup], notice: 'Great, we’ve saved your SSH key.'
    rescue
      if @authentication.errors[:public_key].any?
        flash.alert = 'Your SSH key ' + @authentication.errors[:public_key].to_sentence
      else
        flash.alert = 'There was a problem saving your SSH key.'
      end
      redirect_to [@website, :setup]
    end
  end

  private

  def authentication_params
    params.require(:authentication).permit(
      :public_key,
    )
  end
end

class SshKeysController < ApplicationController
  before_action :require_user

  before_action only: %i[update] do
    unless params[:password].present? && current_user.authenticate(params[:password])
      flash.now.alert = t('.alert_incorrect')
      render :edit, status: 422
    end
  end

  def update
    if current_user.update(ssh_key_params)
      redirect_to :edit_account_ssh_keys, notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :edit, status: 422
    end
  end

  private

  def ssh_key_params
    params.require(:user).permit(
      authentication_attributes: [
        :id,
        :public_key,
      ],
    )
  end
end

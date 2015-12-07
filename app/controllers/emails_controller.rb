class EmailsController < ApplicationController
  before_action :require_user

  before_action only: %i[update] do
    unless params[:password].present? && current_user.authenticate(params[:password])
      flash.now.alert = t('.alert_incorrect')
      render :edit, status: 422
    end
  end

  def update
    value = current_user.email

    if current_user.update(email_params)
      if value != current_user.pending_email
        UserMailer.email_confirmation(current_user).deliver_later
	flash.notice = t('.notice')
      end
      redirect_to :edit_account_email
    else
      flash.now.alert = t('.alert')
      render :edit, status: 422
    end
  end

  def destroy
    current_user.update_column :pending_email, nil
    redirect_to :edit_account_email, notice: t('.notice')
  end

  private

  def email_params
    params.require(:user).permit(
      :email_update,
    )
  end
end

class FormResponderActivationsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch

  before_action do
    @form_responder = @website.form_responders.find(params[:form_responder_id])
  end

  def create
    if @form_responder.update(active: true)
      redirect_to [@website, @branch], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :new, status: 422
    end
  end

  def destroy
    if @form_responder.update(active: false)
      redirect_to [@website, @branch], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :delete, status: 422
    end
  end
end

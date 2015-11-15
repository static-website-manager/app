class FormResponderSubmissionsController < ActionController::Base
  before_action do
    @form_responder = FormResponder.find_by_path_id!(params[:form_responder_id])
  end

  before_action do
    unless @form_responder.active?
      render :invalid
    end

    unless success_redirect_uri.try(:host).present? && success_redirect_uri.host !~ /#{ENV['HOST']}\z/
      render :invalid
    end

    unless fail_redirect_uri.try(:host).present? && fail_redirect_uri.host !~ /#{ENV['HOST']}\z/
      render :invalid
    end
  end

  def create
    if @form_responder.append_data(form_params)
      redirect_to success_redirect_uri.to_s
    else
      redirect_to fail_redirect_uri.to_s
    end
  end

  def update
    if @form_responder.update_data(params[:id], form_params)
      redirect_to success_redirect_uri.to_s
    else
      redirect_to fail_redirect_uri.to_s
    end
  end

  private

  def fail_redirect_uri
    URI.parse(params[:fail_redirect_url]) rescue nil
  end

  def form_params
    params.except(:_method, :action, :controller, :fail_redirect_url, :form_responder_id, :id, :success_redirect_url)
  end

  def success_redirect_uri
    URI.parse(params[:success_redirect_url]) rescue nil
  end
end

class FormRespondersController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch

  before_action only: %i[new create] do
    @form_responder = @website.form_responders.new(active: true, branch_name: @branch.name)
  end

  before_action only: %i[edit update delete destroy] do
    @form_responder = @website.form_responders.find(params[:id])
  end

  before_action only: %i[new create edit update] do
    @dataset_pathnames = Dataset.all(@repository.rugged_repository, @branch.commit_id, per_page: 100).map(&:pretty_pathname)
  end

  def create
    @form_responder.assign_attributes(form_responder_params)

    if @form_responder.save
      redirect_to [@website, @branch], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :new, status: 422
    end
  end

  def update
    if @form_responder.update(form_responder_params)
      redirect_to [@website, @branch], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :edit, status: 422
    end
  end

  def destroy
    if @form_responder.destroy
      redirect_to [@website, @branch], notice: t('.notice')
    else
      flash.now.alert = t('.alert')
      render :delete, status: 422
    end
  end

  private

  def form_responder_params
    params.require(:form_responder).permit(
      :dataset_pathname,
      :email_addresses,
    )
  end
end

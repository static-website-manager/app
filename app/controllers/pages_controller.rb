class PagesController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  before_action only: %i[edit update] do
    @page = @branch.find_page(params[:id])
    @commits = @page.commits(@branch.target, per_page: 10)
  end

  def index
    @pages = @branch.pages
  end

  def update
    if @page.raw_content == page_content
      redirect_to edit_website_branch_page_path(@website, @branch, @page), alert: 'No changes detected.'
    elsif new_page_id = PageWriterService.perform(current_user, @website, @branch, @page, page_content, params[:message])
      redirect_to edit_website_branch_page_path(@website, @branch, new_page_id), notice: 'Great, we’ve committed your changes.'
    else
      flash.now.alert = 'There was a problem saving your changes.'
      render :edit, status: 422
    end
  end

  private

  def page_content
    [YAML.dump((params[:page].try(:[], :metadata) || {}).to_hash), params[:page].try(:[], :content) || ''].join("---\n\n")
  end
end

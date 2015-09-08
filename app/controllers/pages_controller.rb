class PagesController < ApplicationController
  include WebsiteManagementConcern
  include BranchManagementConcern

  before_action only: %i[edit update] do
    @page = @branch.find_page(params[:id])
    @commits = @page.commits(@branch.target, per_page: 10)
    @blob_commit = BlobCommit.new(current_user, @website, @branch, @page)
  end

  def index
    @pages = @branch.pages
  end

  def update
    @blob_commit.save(page_content, params[:message])

    if @blob_commit.id.present? && @blob_commit.id == @page.id
      redirect_to edit_website_branch_page_path(@website, @branch, @page), alert: 'No changes detected.'
    elsif @blob_commit.id.present?
      redirect_to edit_website_branch_page_path(@website, @branch, @blob_commit.id), notice: 'Great, we’ve committed your changes.'
    else
      flash.now.alert = 'There was a problem saving your changes.'
      render :edit, status: 422
    end
  end

  private

  def page_content
    if params[:page].try(:[], :metadata).present?
      [YAML.dump(params[:page][:metadata].to_hash), @page.writable? ? params[:page].try(:[], :content) || '' : @page.content].join("---\n\n")
    else
      @page.writable? ? params[:page].try(:[], :content) || '' : @page.content
    end
  end
end

class BranchMovesController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch

  before_action do
    unless @branch.custom?
      redirect_to [@website, @branch]
    end
  end

  def create
    begin
      raise ArgumentError if params[:name] == 'master' || params[:name].to_s.match(/\Astatic_user_/)
      ref_name = @repository.move_branch(@branch.name, params[:name]).name.split('/').last
      @deployment.update_column :branch_name, ref_name if @deployment
      redirect_to website_branch_path(@website, ref_name), notice: 'Great, we’ve committed your changes.'
    rescue
      flash.now.alert = 'There was a problem saving your changes.'
      render :new, status: 422
    end
  end
end

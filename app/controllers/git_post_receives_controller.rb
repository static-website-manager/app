class GitPostReceivesController < ActionController::Base
  before_action do
    unless ENV['GIT_HOOK_TOKEN'] == params[:token]
      raise ActionController::RoutingError.new('Unauthenticated Token')
    end
  end

  before_action do
    @website = Website.find(params[:website_id])
    @repository = Repository.new(website_id: @website.id)

    begin
      @branch = @repository.branch(params[:branch_name])
    rescue
      if deployment = @website.deployments.find_by_branch_name(params[:branch_name])
        deployment.destroy
        render text: t('.removed', branch_name: params[:branch_name], deployment_url: deployment.url)
      else
        render text: ''
      end
    end
  end

  def create
    @messages = []
    if @branch.production?
      deploy(@branch, force: @website.auto_create_production_deployment?)

      @website.users.each do |user|
        branch = @repository.branch(user, auto_create_staging: false) rescue nil

        if branch
          if @website.auto_rebase_staging_on_production_changes? && branch.rebase_required?(@branch)
            if branch.rebase(@branch)
              deploy(branch)
            end
          else
            deploy(branch)
          end
        else
          deploy(@repository.branch(user), force: @website.auto_create_staging_deployment?)
        end
      end
    elsif @branch.staging?
      deploy(@branch, force: @website.auto_create_staging_deployment?)
    else
      deploy(@branch)
    end

    render text: @messages.join("\n")
  end

  private

  def deploy(branch, force: false)
    deployment = @website.deployments.where(branch_name: branch.name).send(force ? :first_or_create : :first)

    if deployment && deployment.persisted?
      JekyllBuildJob.perform_later(deployment)
      @messages << t('.scheduled', branch_name: branch.name, deployment_url: deployment.url)
    else
      @messages << t('.received', branch_name: branch.name)
    end
  end
end

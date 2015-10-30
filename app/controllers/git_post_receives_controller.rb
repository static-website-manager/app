class GitPostReceivesController < ActionController::Base
  before_action do
    unless ENV['GIT_HOOK_TOKEN'] == params[:token]
      raise ActionController::RoutingError.new("Unauthenticated Token – #{ENV['GIT_HOOK_TOKEN']} – #{params[:token]}")
    end
  end

  before_action do
    @website = Website.find(params[:website_id])
    @repository = Repository.new(website_id: @website.id)
    @branch = @repository.branch(params[:branch_name])
  end

  def create
    @messages = []

    if @branch.production?
      deploy(@branch, force: @website.auto_deploy_production?)

      @website.users.each do |user|
        deploy(@repository.branch(user), force: @website.auto_deploy_staging?)
      end
    elsif @branch.staging?
      deploy(@branch, force: @website.auto_deploy_staging?)
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

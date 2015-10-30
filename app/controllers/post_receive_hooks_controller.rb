class PostReceiveHooksController < ActionController::Base
  # TODO Secure Access
  def create
    website = Website.find_by_id(params[:website_id])

    if website
      deployments = website.deployments.where(branch_name: params[:branch_name])

      if params[:branch_name] == 'master' && website.auto_deploy_production?
        deployment = deployments.first_or_create
      elsif params[:branch_name].to_s.match(/\Astatic_user_\d{1,9}\z/) && website.auto_deploy_staging?
        deployment = deployments.first_or_create
      else
        deployment = deployments.first
      end

      if deployment
        JekyllBuildJob.perform_later(deployment)
        render text: t('.schedule', branch_name: params[:branch_name], deployment_url: deployment.url)
      else
        render text: t('.receive', branch_name: params[:branch_name])
      end
    end
  end
end

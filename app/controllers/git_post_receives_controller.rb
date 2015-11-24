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
      render text: ''
    end
  end

  def create
    @messages = []

    if @branch.production?
      deploy(@branch)

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
          deploy(@repository.branch(user))
        end
      end
    elsif @branch.staging?
      deploy(@branch)
    else
      deploy(@branch)
    end

    render text: @messages.join("\n")
  end

  private

  def deploy(branch)
    JekyllBuildJob.perform_later(@website.id, branch.name, branch.commit_id)
  end
end

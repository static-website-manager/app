module WebsiteManagementConcern
  extend ActiveSupport::Concern

  included do
    before_action :require_user

    # Set the current user‘s website and ensure its repository is setup.
    before_action do
      @website = current_user.websites.find(params[:website_id])
      @repository = @website.repository

      unless @repository.setup?
        redirect_to [:new, @website, :setup], alert: 'Please complete your website setup to access those features.'
      end
    end
  end
end

module WebsiteManagementConcern
  extend ActiveSupport::Concern

  included do
    before_action :require_user

    # Set the current user‘s website.
    before_action do
      @website = current_user.websites.find(params[:website_id])
    end
  end
end

module WebsiteManagementConcern
  extend ActiveSupport::Concern

  included do
    before_action :require_user

    before_action do
      @website = current_user.websites.find(params[:website_id])
    end
  end
end

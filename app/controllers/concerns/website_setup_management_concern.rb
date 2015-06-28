module WebsiteSetupManagementConcern
  extend ActiveSupport::Concern

  included do
    # Ensure the website is setup.
    before_action do
      unless @website.setup?
        redirect_to [:new, @website, :setup], alert: 'Please complete your website setup to access those features.'
      end
    end
  end
end

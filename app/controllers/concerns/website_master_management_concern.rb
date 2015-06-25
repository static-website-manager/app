module WebsiteMasterManagementConcern
  extend ActiveSupport::Concern

  included do
    before_action do
      unless @website.repository.setup?
        redirect_to [:new, @website, :setup], alert: 'Please push your master branch to access those features.'
      end
    end
  end
end

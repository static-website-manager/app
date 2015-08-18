class SetupsController < ApplicationController
  include WebsiteManagementConcern

  before_action do
    if @website.setup?
      redirect_to [@website, @website.branch(current_user)]
    end
  end
end

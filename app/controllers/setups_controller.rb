class SetupsController < ApplicationController
  include WebsiteConcern

  before_action do
    if @website.setup?
      redirect_to [@website, @website.branch(current_user)]
    end
  end
end

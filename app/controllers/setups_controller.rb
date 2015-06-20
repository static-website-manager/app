class SetupsController < ApplicationController
  before_action do
    @website = Website.find(params[:website_id])
  end
end

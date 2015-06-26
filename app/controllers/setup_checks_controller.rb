class SetupChecksController < ApplicationController
  include WebsiteManagementConcern

  def show
    if @website.repository.setup?
      render text: url_for([@website, @website.branch(current_user)])
    else
      render text: ''
    end
  end
end

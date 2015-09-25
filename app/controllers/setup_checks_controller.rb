class SetupChecksController < ApplicationController
  include WebsiteConcern

  def show
    if @website.setup?
      render text: url_for([@website, @website.branch(current_user)])
    else
      render text: ''
    end
  end
end

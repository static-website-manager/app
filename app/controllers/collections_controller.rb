class CollectionsController < ApplicationController
  before_action :require_user
  before_action :require_website
  before_action :require_designer
  before_action :require_repository
  before_action :require_setup
  before_action :require_branch
  before_action :set_return_to
end

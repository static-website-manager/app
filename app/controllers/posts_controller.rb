class PostsController < ApplicationController
  include WebsiteManagementConcern
  include WebsiteSetupManagementConcern
  include BranchManagementConcern
end

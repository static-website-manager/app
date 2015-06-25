class PostsController < ApplicationController
  include WebsiteManagementConcern
  include WebsiteMasterManagementConcern
  include BranchManagementConcern
end

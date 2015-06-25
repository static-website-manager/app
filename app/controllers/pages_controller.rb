class PagesController < ApplicationController
  include WebsiteManagementConcern
  include WebsiteMasterManagementConcern
  include BranchManagementConcern
end

class PagesController < ApplicationController
  include WebsiteManagementConcern
  include WebsiteSetupManagementConcern
  include BranchManagementConcern
end

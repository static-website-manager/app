class Deployment < ActiveRecord::Base
  belongs_to :website

  validates :website, presence: true
  validates :branch_name, presence: true
end

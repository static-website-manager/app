class Website < ActiveRecord::Base
  has_many :authorizations, dependent: :destroy
  has_many :users, through: :authorizations

  has_many :deployments, dependent: :destroy

  validates :name, presence: true
end

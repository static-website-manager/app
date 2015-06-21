class Website < ActiveRecord::Base
  has_many :authorizations, dependent: :destroy
  has_many :users, through: :authorizations

  validates :name, presence: true

  def repository
    Repository.new(id.to_s) if persisted?
  end
end

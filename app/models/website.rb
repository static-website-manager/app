class Website < ActiveRecord::Base
  has_many :authorizations, dependent: :destroy
  has_many :users, through: :authorizations

  validates :name, presence: true

  def repository
    Repository.new(id)
  end

  def branch(name)
    Branch.new(repository, name)
  end
end

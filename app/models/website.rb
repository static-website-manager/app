class Website < ActiveRecord::Base
  has_many :authorizations, dependent: :destroy
  has_many :users, through: :authorizations

  validates :name, presence: true

  def repository
    directory = Rails.root.join("repos/#{id}.git")

    if directory.exist?
      Rugged::Repository.new(directory.to_s)
    else
      Rugged::Repository.init_at(directory.to_s, :bare)
    end
  end
end

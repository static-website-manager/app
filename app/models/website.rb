class Website < ActiveRecord::Base
  has_many :authorizations, dependent: :destroy
  has_many :users, through: :authorizations

  validates :name, presence: true

  def branch(name_or_user)
    Branch.find(rugged_repository, name_or_user)
  end

  def custom_branch_names
    rugged_repository.branches.each_name(:local).sort.reject do |name|
      name == 'master' || name.match(/\Aswm_user_\d+\z/)
    end
  end

  def setup?
    !rugged_repository.empty? && rugged_repository.branches['master']
  end

  private

  def repository_pathname
    @repository_pathname ||= Rails.root.join('repos', "#{id}.git")
  end

  def rugged_repository
    @rugged_repository ||= Rugged::Repository.send(repository_pathname.exist? ? :new : :init, repository_pathname.to_s)
  end
end

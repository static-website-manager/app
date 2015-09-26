class Website < ActiveRecord::Base
  has_many :authorizations, dependent: :destroy
  has_many :users, through: :authorizations

  validates :name, presence: true

  def branch(name_or_user)
    Branch.find(rugged_repository, name_or_user)
  end

  def commit(commit_id)
    rugged_commit = rugged_repository.lookup(commit_id)
    raise ActiveRecord::RecordNotFound unless rugged_commit
    Commit.new(rugged_repository, rugged_commit)
  end

  def repository_pathname
    @repository_pathname ||= Rails.root.join(Rails.application.secrets.repos_dir, "#{id}.git")
  end

  def rugged_repository
    if persisted?
      @rugged_repository ||= repository_pathname.exist? ? Rugged::Repository.new(repository_pathname.to_s) : Rugged::Repository.init_at(repository_pathname.to_s, :bare)
    end
  end
end

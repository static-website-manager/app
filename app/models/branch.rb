class Branch
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def self.find(rugged_repository, name_or_user)
    raw_name = name_or_user.is_a?(User) ? "user_#{name_or_user.id}" : name_or_user.to_s
    rugged_branch = rugged_repository.branches[raw_name]
    if rugged_branch
      new(rugged_repository, rugged_branch)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def initialize(rugged_repository, rugged_branch)
    @rugged_repository = rugged_repository
    @rugged_branch = rugged_branch
  end

  def commit
    Commit.new(@rugged_repository, @rugged_branch.target)
  end

  def commits
    Rugged::Walker.new(@rugged_repository).tap do |walker|
      walker.sorting Rugged::SORT_TOPO
      walker.push @rugged_branch.target
    end.map do |rugged_commit|
      Commit.new(@rugged_repository, rugged_commit)
    end
  end

  def raw_name
    @rugged_branch.name
  end

  def name
    raw_name.match(/\Auser_\d+\z/) ? 'working' : raw_name
  end

  def master?
    name == 'master'
  end

  def working?
    name == 'working'
  end

  def to_param
    name
  end

  def persisted?
    true
  end
end

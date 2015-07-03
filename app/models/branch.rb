class Branch
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_reader :name

  def initialize(rugged_repository, name_or_user)
    @name = name_or_user.is_a?(User) ? 'working' : name_or_user.to_s
    @raw_name = name_or_user.is_a?(User) ? "user_#{name_or_user.id}" : name_or_user.to_s
    @rugged_repository = rugged_repository
    @rugged_branch = @rugged_repository.branches[@raw_name]
  end

  def commit
    Commit.new(@rugged_branch.target)
  end

  def commits
    Rugged::Walker.new(@rugged_repository).tap do |walker|
      walker.push @rugged_branch.target
    end.map do |rugged_commit|
      Commit.new(rugged_commit)
    end
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

class Commit
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def initialize(rugged_repository, rugged_commit)
    @rugged_repository = rugged_repository
    @rugged_commit = rugged_commit
  end

  def author_name
    @rugged_commit.author[:name]
  end

  def author_email
    @rugged_commit.author[:email]
  end

  def diff
    if @rugged_commit.parents.any?
      Diff.new(@rugged_commit.parents[0].diff(@rugged_commit))
    else
      Diff.new(@rugged_commit.diff)
    end
  end

  def id
    @rugged_commit.oid
  end

  def short_id
    id[0..6]
  end

  def message
    @rugged_commit.message
  end

  def parent_ids
    @rugged_commit.parent_ids
  end

  def time
    @rugged_commit.time
  end

  def persisted?
    true
  end
end

class Commit
  def initialize(rugged_commit)
    @rugged_commit = rugged_commit
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

  def tree
    Tree.new(@rugged_commit.tree)
  end
end

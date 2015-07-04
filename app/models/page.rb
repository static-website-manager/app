class Page
  include ActiveModel::Conversion

  attr_reader :name, :id, :mode, :type

  def initialize(rugged_repository, name, id, mode, type)
    @rugged_repository = rugged_repository
    @name = name
    @id = id
    @mode = mode
    @type = type
  end

  def commit(sha)
    walker = Rugged::Walker.new(@rugged_repository)
    walker.sorting(Rugged::SORT_DATE)
    walker.push(sha)
    commits = walker.to_a
    Commit.new(@rugged_repository, commits.find { |c| c.parents.size == 1 && c.diff(paths: [@name]).size > 0 } || commits.last)
  end

  def size
    rugged_blob.size unless tree?
  end

  def tree?
    @type == :tree
  end

  private

  def rugged_blob
    @rugged_blob ||= @rugged_repository.lookup(@id)
  end
end

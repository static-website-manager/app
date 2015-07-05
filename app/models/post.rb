class Post
  include ActiveModel::Conversion

  attr_reader :name, :id, :mode, :type

  def initialize(rugged_repository, name, id, mode, type, draft: false)
    @rugged_repository = rugged_repository
    @name = name
    @id = id
    @mode = mode
    @type = type
    @draft = draft
  end

  def draft?
    !!@draft
  end

  def size
    rugged_blob.size
  end

  private

  def rugged_blob
    @rugged_blob ||= @rugged_repository.lookup(@id)
  end
end

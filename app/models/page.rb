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

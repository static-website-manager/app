class PageTree
  include ActiveModel::Conversion

  attr_reader :name, :id, :type, :path
  attr_accessor :objects

  def initialize(rugged_repository, name, id, mode, type, path)
    @rugged_repository = rugged_repository
    @name = name
    @id = id
    @mode = mode
    @type = type
    @objects = []
    @path = path
  end
end

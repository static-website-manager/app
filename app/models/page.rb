class Page
  include ActiveModel::Conversion

  attr_reader :name

  def initialize(name, id, mode, type)
    @name = name
    @id = id
    @mode = mode
    @type = type
  end

  def tree?
    @type == :tree
  end
end

class Post
  include ActiveModel::Conversion

  attr_reader :name

  def initialize(name, id, mode, type, draft: false)
    @name = name
    @id = id
    @mode = mode
    @type = type
    @draft = draft
  end
end

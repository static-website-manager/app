class Post
  include ActiveModel::Conversion

  attr_reader :name

  def initialize(name, oid, mode, type)
    @name = name
  end
end

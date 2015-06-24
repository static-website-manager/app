class Post
  include ActiveModel::Conversion

  attr_reader :name

  def initialize(repo, name, oid, mode, type)
    @name = name
  end
end

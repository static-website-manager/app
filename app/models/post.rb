class Post
  include ActiveModel::Conversion

  attr_reader :filename

  def initialize(commit_id, filename)
    @commit_id = commit_id
    @filename = filename
  end
end

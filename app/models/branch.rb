class Branch
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def initialize(repository, name)
    @repository = repository
    @branch = @repository.find_branch(name)
  end

  def target
    @branch.target
  end

  def tree
    target.tree
  end

  def drafts_tree
    @repository.lookup tree['_drafts'].try(:[], :oid)
  end

  def drafts
    (drafts_tree || []).map do |object|
      Post.new(*object.values)
    end
  end

  def posts_tree
    @repository.lookup tree['_posts'].try(:[], :oid)
  end

  def posts
    (posts_tree || []).map do |object|
      Post.new(*object.values)
    end
  end

  def pages
    tree.map do |object|
      Page.new(*object.values) unless object[:name].match(/\A_/)
    end.compact
  end

  def name
    @branch.name.match(/\Auser_\d+\z/) ? 'working' : @branch.name
  end

  def persisted?
    true
  end

  def to_param
    name
  end
end

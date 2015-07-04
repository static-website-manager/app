class Tree
  def initialize(rugged_repository, rugged_tree)
    @rugged_repository = rugged_repository
    @rugged_tree = rugged_tree
  end

  def pages
    @rugged_tree.map do |object|
      if object[:name].match(/\A[a-zA-Z0-9]+/)
        object
      end
    end.compact.sort do |a, b|
      [a[:type] == :tree ? 0 : 1, a[:name]] <=> [b[:type] == :tree ? 0 : 1, b[:name]]
    end.map do |object|
      Page.new(@rugged_repository, *object.values)
    end
  end

  def posts
    drafted_posts + published_posts
  end

  private

  def drafted_posts
    if @rugged_tree['_drafts']
      @rugged_tree.repo.lookup(@rugged_tree['_drafts'][:oid]).map do |object|
        if object[:type] == :blob && object[:name].match(/.+\.(html|markdown|md)\z/)
          Post.new(@rugged_repository, *object.values, draft: true)
        end
      end.compact
    else []
    end
  end

  def published_posts
    if @rugged_tree['_posts']
      @rugged_tree.repo.lookup(@rugged_tree['_posts'][:oid]).map do |object|
        if object[:type] == :blob && object[:name].match(/.+\.(html|markdown|md)\z/)
          Post.new(@rugged_repository, *object.values)
        end
      end.compact
    else []
    end
  end
end

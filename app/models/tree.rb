class Tree
  def initialize(rugged_tree)
    @rugged_tree = rugged_tree
  end

  def pages
    @rugged_tree.map do |object|
      if object[:name].match(/\A[a-zA-Z0-9]+/)
        Page.new(*object.values)
      end
    end.compact
  end

  def posts
    drafted_posts + published_posts
  end

  private

  def drafted_posts
    if @rugged_tree['_drafts']
      @rugged_tree.repo.lookup(@rugged_tree['_drafts'][:oid]).map do |object|
        if object[:type] == :blob && object[:name].match(/.+\.(html|markdown|md)\z/)
          Post.new(*object.values)
        end
      end.compact
    else []
    end
  end

  def published_posts
    if @rugged_tree['_posts']
      @rugged_tree.repo.lookup(@rugged_tree['_posts'][:oid]).map do |object|
        if object[:type] == :blob && object[:name].match(/.+\.(html|markdown|md)\z/)
          Post.new(*object.values)
        end
      end.compact
    else []
    end
  end
end

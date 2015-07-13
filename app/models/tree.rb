class Tree
  def initialize(rugged_repository, rugged_tree)
    @rugged_repository = rugged_repository
    @rugged_tree = rugged_tree
  end

  def pages
    hash = {}

    @rugged_tree.walk(:postorder).select do |root, object|
      !root.match(/\A_/) && (object[:type] == :tree || object[:name].match(/\.(html|markdown|md)\z/))
    end.each do |root, object|
      (hash[root] ||= []) << object
    end

    arrange(hash, '', PageTree, Page)
  end

  def drafts
    hash = {}

    @rugged_tree.walk(:postorder).select do |root, object|
      root.match(/\A_drafts/) && (object[:type] == :tree || object[:name].match(/\.(html|markdown|md)\z/))
    end.each do |root, object|
      (hash[root] ||= []) << object
    end

    arrange(hash, '_drafts/', DraftTree, Draft)
  end

  def posts
    hash = {}

    @rugged_tree.walk(:postorder).select do |root, object|
      root.match(/\A_posts/) && (object[:type] == :tree || object[:name].match(/\.(html|markdown|md)\z/))
    end.each do |root, object|
      (hash[root] ||= []) << object
    end

    arrange(hash, '_posts/', PostTree, Post, reverse_blobs: true)
  end

  private

  def arrange(hash, root, tree_class, blob_class, options = {})
    trees = Array(hash[root]).select do |object|
      object[:type] == :tree
    end.map do |object|
      tree_class.new(@rugged_repository, *object.values)
    end.sort_by(&:name)

    blobs = Array(hash[root]).select do |object|
      object[:type] == :blob
    end.map do |object|
      blob_class.new(@rugged_repository, *object.values)
    end.sort_by(&:name)

    if options[:reverse_blobs]
      blobs.reverse!
    end

    trees.each do |tree|
      tree.objects = arrange(hash, root + tree.name + '/', tree_class, blob_class, options)
    end

    trees.reject { |t| t.objects.empty? } + blobs
  end
end

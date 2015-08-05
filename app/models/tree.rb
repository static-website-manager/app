class Tree
  def initialize(rugged_repository, rugged_tree)
    @rugged_repository = rugged_repository
    @rugged_tree = rugged_tree
  end

  def find_draft(id)
    find(Draft, id)
  end

  def find_page(id)
    find(Page, id)
  end

  def find_post(id)
    find(Post, id)
  end

  def pages
    select('', PageTree, Page) do |root, object|
      !root.match(/\A_/) && (object[:type] == :tree || object[:name].match(/\.(html|markdown|md)\z/))
    end
  end

  def drafts
    select('_drafts/', DraftTree, Draft) do |root, object|
      root.match(/\A_drafts/) && (object[:type] == :tree || object[:name].match(/\.(html|markdown|md)\z/))
    end
  end

  def posts
    select('_posts/', PostTree, Post, reverse_blobs: true) do |root, object|
      root.match(/\A_posts/) && (object[:type] == :tree || object[:name].match(/\.(html|markdown|md)\z/))
    end
  end

  private

  def find(blob_class, id)
    object = @rugged_tree.walk(:postorder).find do |root, object|
      if object[:oid] == id
        object[:root] = root
      end
    end

    if object
      blob_class.new(@rugged_repository, *object[1].values)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def select(*args)
    hash = {}

    @rugged_tree.walk(:postorder).select do |root, object|
      yield root, object
    end.each do |root, object|
      (hash[root] ||= []) << object
    end

    arrange(hash, *args)
  end

  def arrange(hash, root, tree_class, blob_class, options = {})
    trees = Array(hash[root]).select do |object|
      object[:type] == :tree
    end.map do |object|
      tree_class.new(@rugged_repository, *object.values, root)
    end.sort_by(&:name)

    blobs = Array(hash[root]).select do |object|
      object[:type] == :blob
    end.map do |object|
      blob_class.new(@rugged_repository, *object.values, root)
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

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

    def arrange(hash, root)
      trees = Array(hash[root]).select do |object|
        object[:type] == :tree
      end.map do |object|
        PageTree.new(object[:name])
      end.sort_by(&:name)

      blobs = Array(hash[root]).select do |object|
        object[:type] == :blob
      end.map do |object|
        Page.new(@rugged_repository, *object.values, root)
      end.sort_by(&:name).sort do |blob|
        blob.name.match(/\Aindex\./) ? 0 : 1
      end

      trees.each do |tree|
        tree.objects = arrange(hash, root + tree.name + '/')
      end

      blobs + trees.reject { |t| t.objects.empty? }
    end

    collection = arrange(hash, '')

    if root = collection.find { |object| object.is_a?(Page) && object.name.match(/\Aindex\.(html|markdown|md)\z/) }
      collection.delete(root)
      root.objects = collection
      collection = [root]
    end

    def extract(collection)
      collection.map do |object|
        if root = (object.objects || []).find { |o| o.is_a?(Page) && o.name.match(/\Aindex\.(html|markdown|md)\z/) }
          object.objects.delete(root)
          root.objects = extract(object.objects || [])
          root.node_name = object.name
          root
        else
          object.objects = extract(object.objects || [])
          object
        end
      end
    end

    extract collection
  end

  def drafts
    @rugged_tree.walk(:postorder).select do |root, object|
      root.match(/\A_drafts/) && object[:name].match(/\.(html|markdown|md)\z/)
    end.map do |root, object|
      Draft.new(@rugged_repository, *object.values, root)
    end
  end

  def posts
    @rugged_tree.walk(:postorder).select do |root, object|
      root.match(/\A_posts/) && object[:name].match(/\.(html|markdown|md)\z/)
    end.map do |root, object|
      Post.new(@rugged_repository, *object.values, root)
    end
  end

  def find_blob(blob_class, oid)
    object = @rugged_tree.walk(:postorder).find do |root, object|
      if object[:oid] == oid
        object[:root] = root
      end
    end

    if object
      blob_class.new(@rugged_repository, *object[1].values)
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end

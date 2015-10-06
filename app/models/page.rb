class Page
  include ActiveModel::Model
  include BlobConcern

  attr_accessor :dirname, :objects

  def self.all(rugged_repository, commit_id)
    result_hash = {}

    rugged_repository.lookup(commit_id).tree.walk(:postorder).select do |root, object|
      !root.match(/\A_/) && (object[:type] == :tree || object[:name].match(/\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/))
    end.each do |root, object|
      (result_hash[root] ||= []) << object
    end

    squash_index_blobs(
      squash_root_index_blob(
        arrange_hash_into_nested_collection(result_hash, '')
      )
    )
  end

  def self.find(*args)
    super *args.push(/(\A(\/|[^_]+)|\A\z)/)
  end

  def title
    filename.split('.').first.titleize
  end

  private

  def self.arrange_hash_into_nested_collection(hash, root)
    trees = Array(hash[root]).select do |object|
      object[:type] == :tree
    end.map do |object|
      PageTree.new(filename: object[:name])
    end.sort_by(&:filename)

    blobs = Array(hash[root]).select do |object|
      object[:type] == :blob
    end.map do |object|
      Page.new(
        id: object[:oid],
        filename: object[:name],
        pathname: root,
        rugged_repository: @rugged_repository,
      )
    end.sort_by(&:filename).sort do |blob|
      blob.filename.match(/\Aindex\./) ? 0 : 1
    end

    trees.each do |tree|
      tree.objects = arrange_hash_into_nested_collection(hash, root + tree.filename + '/')
    end

    blobs + trees.reject { |t| t.objects.empty? }
  end

  def self.squash_index_blobs(collection)
    collection.map do |object|
      if root = Array(object.objects).find { |o| o.is_a?(Page) && o.filename.match(/\Aindex\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/) }
        object.objects.delete(root)
        root.objects = squash_index_blobs(object.objects || [])
        root.dirname = object.filename
        root
      else
        object.objects = squash_index_blobs(object.objects || [])
        object
      end
    end
  end

  def self.squash_root_index_blob(collection)
    if root = collection.find { |object| object.is_a?(Page) && object.filename.match(/\Aindex\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/) }
      collection.delete(root)
      root.objects = collection
      collection = [root]
    end
    collection
  end
end

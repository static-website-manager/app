class StaticFile
  include ActiveModel::Model
  include BlobConcern

  attr_accessor :dirname, :objects

  def self.all(rugged_repository, commit_id)
    result_hash = {}

    rugged_repository.lookup(commit_id).tree.walk(:postorder).select do |root, object|
      !root.match(/\A_/) && (object[:type] == :tree || !object[:name].match(/\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/))
    end.each do |root, object|
      (result_hash[root] ||= []) << object
    end

    arrange_hash_into_nested_collection(result_hash, '')
  end

  def self.find(*args)
    super *args.push(/(\A(\/|[^_]+)|\A\z)/)
  end

  private

  def self.arrange_hash_into_nested_collection(hash, root)
    trees = Array(hash[root]).select do |object|
      object[:type] == :tree
    end.map do |object|
      StaticFileTree.new(filename: object[:name])
    end.sort_by(&:filename)

    blobs = Array(hash[root]).select do |object|
      object[:type] == :blob
    end.map do |object|
      StaticFile.new(
        id: object[:oid],
        filename: object[:name],
        pathname: root,
        rugged_repository: @rugged_repository,
      )
    end.sort_by(&:filename)

    trees.each do |tree|
      tree.objects = arrange_hash_into_nested_collection(hash, root + tree.filename + '/')
    end

    blobs + trees.reject { |t| t.objects.empty? }
  end
end

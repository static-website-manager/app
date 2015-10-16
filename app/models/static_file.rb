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

  def self.find(rugged_repository, commit_id, pathname)
    result = rugged_repository.lookup(commit_id).tree.walk(:postorder).find do |root, object|
      File.join([root, object[:name]].reject(&:blank?)) == pathname
    end

    if result && result[0].match(/(\A(\/|[^_]+)|\A\z)/)
      rugged_blob = rugged_repository.lookup(result[1][:oid])
      new(
        id: result[1][:oid],
        filename: result[1][:name],
        pathname: result[0],
        rugged_blob: rugged_blob,
        rugged_repository: rugged_repository,
      )
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def image?
    extension.match(/\A(gif|ico|jpeg|jpg|png)\z/)
  end

  def preview?
    extension.match(/\A(gif|htm|html|ico|jpeg|jpg|js|json||markdown|mdown|mkdn|mkd|md|png|text|txt|xml|yml)\z/)
  end

  def text?
    extension.match(/\A(htm|html|js|json||markdown|mdown|mkdn|mkd|md|xml|yml)\z/)
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

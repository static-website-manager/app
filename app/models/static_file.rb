class StaticFile
  include BlobConcern

  attr_accessor :dirname, :objects

  def self.all(rugged_repository, commit_id, page_extensions)
    result_hash = {}

    rugged_repository.lookup(commit_id).tree.walk(:postorder).select do |root, object|
      if root.match(HIDDEN_FILE_REGEXP)
        false
      elsif object[:name].match(HIDDEN_FILE_REGEXP)
        false
      elsif object[:type] == :blob && object[:name].match(PAGE_EXTENTIONS_REGEXP_PROC.call(page_extensions))
        rugged_blob = rugged_repository.lookup(object[:oid])

        if rugged_blob.binary?
          true
        elsif rugged_blob.text.match(FRONT_MATTER_REGEXP)
          false
        else
          true
        end
      else
        true
      end
    end.each do |root, object|
      (result_hash[root] ||= []) << object
    end

    arrange_hash_into_nested_collection(result_hash, '')
  end

  def self.find(rugged_repository, commit_id, pathname, page_extensions)
    result = rugged_repository.lookup(commit_id).tree.walk(:postorder).find do |root, object|
      object[:type] == :blob && File.join([root, object[:name]].reject(&:blank?)) == pathname
    end

    if !result
      raise ActiveRecord::RecordNotFound
    elsif result[0].match(HIDDEN_FILE_REGEXP)
      raise ActiveRecord::RecordNotFound
    elsif result[1][:name].match(HIDDEN_FILE_REGEXP)
      raise ActiveRecord::RecordNotFound
    elsif result[1][:name].match(PAGE_EXTENTIONS_REGEXP_PROC.call(page_extensions))
      rugged_blob = rugged_repository.lookup(result[1][:oid])

      if rugged_blob.binary?
        new(
          id: result[1][:oid],
          filename: result[1][:name],
          pathname: result[0],
          rugged_blob: rugged_blob,
          rugged_repository: rugged_repository,
        )
      elsif rugged_blob.text.match(FRONT_MATTER_REGEXP)
        raise ActiveRecord::RecordNotFound
      else
        new(
          id: result[1][:oid],
          filename: result[1][:name],
          pathname: result[0],
          rugged_blob: rugged_blob,
          rugged_repository: rugged_repository,
        )
      end
    else
      rugged_blob = rugged_repository.lookup(result[1][:oid])
      new(
        id: result[1][:oid],
        filename: result[1][:name],
        pathname: result[0],
        rugged_blob: rugged_blob,
        rugged_repository: rugged_repository,
      )
    end
  end

  def image?
    extension.match(/\A(gif|ico|jpeg|jpg|png)\z/)
  end

  def preview?
    image? || !rugged_blob.binary?
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

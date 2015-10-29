class Page
  include BlobConcern
  include PageConcern

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
          false
        elsif rugged_blob.text.match(FRONT_MATTER_REGEXP)
          true
        else
          false
        end
      elsif object[:type] == :tree
        true
      end
    end.each do |root, object|
      (result_hash[root] ||= []) << object
    end

    squash_index_blobs(
      squash_root_index_blob(
        arrange_hash_into_nested_collection(result_hash, ''),
        page_extensions
      ),
      page_extensions
    )
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
        raise ActiveRecord::RecordNotFound
      elsif rugged_blob.text.match(FRONT_MATTER_REGEXP)
        new(
          content: content(rugged_blob),
          id: result[1][:oid],
          filename: result[1][:name],
          metadata: metadata(rugged_blob),
          pathname: result[0],
          rugged_blob: rugged_blob,
          rugged_repository: rugged_repository,
        )
      else
        raise ActiveRecord::RecordNotFound
      end
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def title(markdown_extensions)
    if pathname.blank? && basename == 'index' && markdown?(markdown_extensions)
      'Home'
    elsif basename == 'index' && markdown?(markdown_extensions)
      pathname.split('/').last.titleize.sub(/\/\z/, '')
    elsif markdown?(markdown_extensions) && basename.match(/\A[A-Z_]+\z/)
      basename
    elsif markdown?(markdown_extensions)
      basename.titleize
    else
      filename
    end
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

  def self.squash_index_blobs(collection, page_extensions)
    collection.map do |object|
      if root = Array(object.objects).find { |o| o.is_a?(Page) && o.filename.match(/\Aindex\.(#{page_extensions.join('|')})\z/) }
        object.objects.delete(root)
        root.objects = squash_index_blobs(object.objects || [], page_extensions)
        root.dirname = object.filename
        root
      else
        object.objects = squash_index_blobs(object.objects || [], page_extensions)
        object
      end
    end
  end

  def self.squash_root_index_blob(collection, page_extensions)
    if root = collection.find { |object| object.is_a?(Page) && object.filename.match(/\Aindex\.(#{page_extensions.join('|')})\z/) }
      collection.delete(root)
      root.objects = collection
      collection = [root]
    end
    collection
  end
end

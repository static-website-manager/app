class Post
  include ActiveModel::Model
  include BlobConcern
  include PageConcern

  def self.all(rugged_repository, commit_id, page: 1, per_page: 20)
    Kaminari.paginate_array(
      rugged_repository.lookup(commit_id).tree.walk(:postorder).select do |root, object|
        root.match(/\A_posts/) && object[:name].match(/\A\d{4}\-\d{2}\-\d{2}\-[\w\-]+\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/)
      end.map do |root, object|
        Post.new(
          id: object[:oid],
          filename: object[:name],
          pathname: root,
          rugged_repository: rugged_repository,
        )
      end.sort_by(&:published_on).reverse
    ).page(page).per(per_page)
  end

  def self.find(rugged_repository, commit_id, pathname)
    result = rugged_repository.lookup(commit_id).tree.walk(:postorder).find do |root, object|
      File.join([root, object[:name]].reject(&:blank?)).sub(/\A_posts\//, '') == pathname
    end

    if result && result[0].match(/\A_posts/)
      rugged_blob = rugged_repository.lookup(result[1][:oid])
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
  end

  def pretty_pathname
    full_pathname.gsub(/\A_posts\//, '')
  end

  def published_on
    Date.new(*filename.match(/\A(\d{4})\-(\d{2})\-(\d{2})\-/)[1..3].map(&:to_i))
  end

  def title
    filename.split('.').first.gsub(/\A\d{4}\-\d{2}\-\d{2}\-/, '').titleize
  end
end

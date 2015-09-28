class Post
  include ActiveModel::Model

  attr_accessor :content, :filename, :id, :pathname, :rugged_blob, :rugged_repository

  def self.find(rugged_repository, commit_id, id)
    result = rugged_repository.lookup(commit_id).tree.walk(:postorder).find do |root, object|
      object[:oid] == id
    end

    if result && result[0].match(/\A_posts/)
      rugged_blob = rugged_repository.lookup(id)
      new(
        content: rugged_blob.content.sub(/\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m, '').force_encoding('utf-8'),
        id: id,
        filename: result[1][:name],
        pathname: result[0],
        rugged_blob: rugged_blob,
        rugged_repository: rugged_repository,
      )
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def self.all(rugged_repository, commit_id, page: 1, per_page: 20)
    Kaminari.paginate_array(
      rugged_repository.lookup(commit_id).tree.walk(:postorder).select do |root, object|
        root.match(/\A_posts/) && object[:name].match(/\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/)
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

  def full_pathname
    File.join([pathname, filename].reject(&:blank?))
  end

  def persisted?
    id.present?
  end

  def pretty_pathname
    full_pathname.gsub(/\A_posts\//, '')
  end

  def published_on
    Date.new(*filename.match(/\A(\d{4})\-(\d{2})\-(\d{2})\-/)[1..3].map(&:to_i))
  end

  def short_id
    id[0..6]
  end

  def to_param
    id
  end

  def title
    filename.split('.').first.gsub(/\A\d{4}\-\d{2}\-\d{2}\-/, '').titleize
  end

  def writable?
    filename.match(/\.(markdown|mdown|mkdn|mkd|md)\z/)
  end
end

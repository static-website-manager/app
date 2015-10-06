class Post
  include ActiveModel::Model
  include BlobConcern

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

  def self.find(*args)
    super *args.push(/\A_posts/)
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

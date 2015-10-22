class Post
  include ActiveModel::Model
  include ActiveModel::Dirty
  include BlobConcern
  include PageConcern

  def self.all(rugged_repository, commit_id, page_extensions, page: 1, per_page: 20)
    Kaminari.paginate_array(
      rugged_repository.lookup(commit_id).tree.walk(:postorder).select do |root, object|
        if root.match(/\A_posts/) && object[:name].match(/\A\d{4}\-\d{2}\-\d{2}\-[\w\-]+\.(#{page_extensions.join('|')})\z/)
          rugged_blob = rugged_repository.lookup(object[:oid])
          rugged_blob && !rugged_blob.binary? && rugged_blob.text.match(FRONT_MATTER_REGEXP)
        end
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

  def self.find(rugged_repository, commit_id, pathname, page_extensions)
    result = rugged_repository.lookup(commit_id).tree.walk(:postorder).find do |root, object|
      object[:type] == :blob && File.join([root, object[:name]].reject(&:blank?)).sub(/\A_posts\//, '') == pathname
    end

    if !result
      raise ActiveRecord::RecordNotFound
    elsif !result[0].match(/\A_posts/)
      raise ActiveRecord::RecordNotFound
    elsif !result[1][:name].match(/\A\d{4}\-\d{2}\-\d{2}\-[\w\-]+\.(#{page_extensions.join('|')})\z/)
      raise ActiveRecord::RecordNotFound
    else
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
    end
  end

  def pretty_pathname
    full_pathname.gsub(/\A_posts\//, '')
  end

  def public_path
    [pathname.sub(/\A_posts\//, ''), filename.match(/\A(\d{4})-(\d{2})-(\d{2})-(.+)\z/)[1..-1].join('/').split('.')[0..-2].join('.')].reject(&:blank?).join('/')
  end

  def public_url(host)
    File.join([host, public_path].reject(&:blank?)).to_s + '.html'
  end

  def published_on
    Date.new(*filename.match(/\A(\d{4})\-(\d{2})\-(\d{2})\-/)[1..3].map(&:to_i))
  end

  def title
    filename.split('.').first.gsub(/\A\d{4}\-\d{2}\-\d{2}\-/, '').titleize
  end
end

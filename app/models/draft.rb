class Draft
  include BlobConcern
  include PageConcern

  validates :pathname, format: { with: /\A_drafts(\/|\z)/ }
  validates :filename, format: { with: /\A[\w\-]+\z/ }

  def self.all(rugged_repository, commit_id, page_extensions, page: 1, per_page: 20)
    Kaminari.paginate_array(
      rugged_repository.lookup(commit_id).tree.walk(:postorder).select do |root, object|
        if root.match(/\A_drafts/) && object[:name].match(/\A[\w\-]+\.(#{page_extensions.join('|')})\z/)
          rugged_blob = rugged_repository.lookup(object[:oid])
          rugged_blob && !rugged_blob.binary? && rugged_blob.text.match(FRONT_MATTER_REGEXP)
        end
      end.map do |root, object|
        new(
          id: object[:oid],
          filename: object[:name],
          pathname: root,
          rugged_repository: rugged_repository,
        )
      end
    ).page(page).per(per_page)
  end

  def self.find(rugged_repository, commit_id, pathname, page_extensions)
    result = rugged_repository.lookup(commit_id).tree.walk(:postorder).find do |root, object|
      File.join([root, object[:name]].reject(&:blank?)).sub(/\A_drafts\//, '') == pathname
    end

    if !result
      raise ActiveRecord::RecordNotFound
    elsif !result[0].match(/\A_drafts/)
      raise ActiveRecord::RecordNotFound
    elsif !result[1][:name].match(/\A[\w\-]+\.(#{page_extensions.join('|')})\z/)
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
    full_pathname.gsub(/\A_drafts\//, '')
  end

  def pretty_pathname_was
    full_pathname_was.gsub(/\A_drafts\//, '')
  end

  def pretty_post_pathname
    full_pathname.gsub(/\A_posts\//, '')
  end

  def title
    filename.split('.').first.titleize
  end
end

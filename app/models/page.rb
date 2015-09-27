class Page
  include ActiveModel::Model

  attr_accessor :dirname, :filename, :id, :objects, :pathname, :rugged_repository

  def self.find(rugged_repository, tree, id)
    result = tree.walk(:postorder).find do |root, object|
      if object[:oid] == id
        object[:root] = root
      end
    end

    if result && !result[1][:root].match(/\A(_drafts|_posts)/)
      new(
        id: id,
        filename: result[1][:name],
        pathname: result[1][:root],
        rugged_repository: rugged_repository,
      )
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def full_pathname
    File.join([pathname, filename].reject(&:blank?))
  end

  def persisted?
    id.present?
  end

  def short_id
    id[0..6]
  end

  def title
    filename.split('.').first.titleize
  end

  def to_param
    id
  end

  def writable?
    filename.match(/\.(markdown|mdown|mkdn|mkd|md)\z/)
  end
end

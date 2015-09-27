class Draft
  include ActiveModel::Model

  attr_accessor :filename, :id, :pathname, :rugged_repository

  def self.find(rugged_repository, commit_id, id)
    result = rugged_repository.lookup(commit_id).tree.walk(:postorder).find do |root, object|
      object[:oid] == id
    end

    if result && result[0].match(/\A_drafts/)
      new(
        id: id,
        filename: result[1][:name],
        pathname: result[0],
        rugged_repository: rugged_repository,
      )
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def self.all(rugged_repository, commit_id)
    rugged_repository.lookup(commit_id).tree.walk(:postorder).select do |root, object|
      root.match(/\A_drafts/) && object[:name].match(/\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/)
    end.map do |root, object|
      Draft.new(
        id: object[:oid],
        filename: object[:name],
        pathname: root,
        rugged_repository: rugged_repository,
      )
    end
  end

  def full_pathname
    File.join([pathname, filename].reject(&:blank?))
  end

  def persisted?
    id.present?
  end

  def pretty_pathname
    full_pathname.gsub(/\A_drafts\//, '')
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

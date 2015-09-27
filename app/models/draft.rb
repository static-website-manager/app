class Draft
  include ActiveModel::Model

  attr_accessor :filename, :id, :pathname, :rugged_repository

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

class Post
  include ActiveModel::Model

  attr_accessor :filename, :id, :pathname, :rugged_repository

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

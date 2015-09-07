class Post < Blob
  extend ActiveModel::Naming

  def pathname
    raw_pathname.gsub(/\A_posts\//, '')
  end

  def published_on
    Date.new(*name.match(/\A(\d{4})\-(\d{2})\-(\d{2})\-/)[1..3].map(&:to_i))
  end

  def title
    name.split('.').first.gsub(/\A\d{4}\-\d{2}\-\d{2}\-/, '').titleize
  end
end

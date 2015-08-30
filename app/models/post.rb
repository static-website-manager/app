class Post < Blob
  extend ActiveModel::Naming

  def pathname
    raw_pathname.gsub(/\A_posts\//, '')
  end

  def title
    name.split('.').first.gsub(/\A\d{4}\-\d{2}-\d{2}-/, '').titleize
  end
end

class Draft < Blob
  extend ActiveModel::Naming

  def pathname
    raw_pathname.gsub(/\A_drafts\//, '')
  end

  def title
    name.split('.').first.titleize
  end
end

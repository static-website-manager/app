class Page < Blob
  extend ActiveModel::Naming

  attr_accessor :objects, :node_name

  def title
    name.split('.').first.titleize
  end
end

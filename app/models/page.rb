class Page
  include BlobConcern
  extend ActiveModel::Naming

  attr_accessor :objects, :node_name
end

class PageTree
  include ActiveModel::Model

  attr_accessor :filename, :objects

  def objects
    Array(@objects)
  end
end

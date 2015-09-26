class PageTree
  include ActiveModel::Model

  attr_accessor :name, :objects

  def objects
    Array(@objects)
  end
end

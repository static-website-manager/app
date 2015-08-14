class PageTree
  include ActiveModel::Conversion

  attr_reader :name
  attr_accessor :objects

  def initialize(name)
    @name = name
    @objects = []
  end
end

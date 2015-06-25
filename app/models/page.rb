class Page
  include ActiveModel::Conversion

  attr_reader :name

  def initialize(name, oid, mode, type)
    @name = name + ('/' if type == :tree).to_s
  end
end

class Page
  include ActiveModel::Conversion

  attr_reader :name

  def initialize(repo, name, oid, mode, type)
    @name = name + ('/' if type == :tree).to_s
  end
end

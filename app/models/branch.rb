class Branch
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_reader :refname

  def initialize(commit_id, refname)
    @commit_id = commit_id
    @refname = refname.split('/').last
  end

  def persisted?
    true
  end

  def to_param
    @refname
  end
end

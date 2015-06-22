class Branch
  attr_reader :refname

  def initialize(commit_id, refname)
    @commit_id = commit_id
    @refname = refname.split('/').last
  end
end

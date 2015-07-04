class Repository
  def initialize(path)
    @pathname = Rails.root.join('repos', "#{path}.git")
    @rugged_repository = Rugged::Repository.send(@pathname.exist? ? :new : :init, @pathname.to_s)
  end

  def branch(name_or_user)
    Branch.find(@rugged_repository, name_or_user)
  end

  def custom_branch_names
    @rugged_repository.branches.each_name(:local).sort.map do |name|
      name unless name == 'master' || name.match(/\Auser_\d+\z/)
    end.compact
  end

  def setup?
    !@rugged_repository.empty? && branch('master')
  end
end

class Repository
  def initialize(path)
    repository_path = Rails.root.join('repos', "#{path}.git")

    if repository_path.exist?
      @repository = Rugged::Repository.new(repository_path.to_s)
    else
      @repository = Rugged::Repository.init_at(repository_path.to_s, :bare)
    end
  end

  def branch_names
    @repository.branches.each_name(:local).to_a.reject do |name|
      name.match(/\Auser_[\d]+\z/)
    end
  end

  def find_branch(user_or_name)
    branch = user_or_name.is_a?(User) ? find_or_create_user_branch(user_or_name) : find_named_branch(user_or_name)
    branch or raise ActiveRecord::RecordNotFound
  end

  def lookup(oid)
    @repository.lookup(oid) if oid.present?
  end

  def setup?
    !@repository.empty? && !!find_named_branch('master')
  end

  private

  def find_or_create_user_branch(user)
    @repository.branches["user_#{user.id}"] || @repository.branches.create("user_#{user.id}", 'master')
  end

  def find_named_branch(name)
    @repository.branches[name]
  end
end

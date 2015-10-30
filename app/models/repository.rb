class Repository
  include ActiveModel::Model

  attr_accessor :website_id

  def self.pathname(website_id)
    Pathname.new(File.join('/repos', "#{website_id}.git"))
  end

  def self.rugged_repository(website_id)
    pathname = pathname(website_id)

    if pathname.present? && pathname.exist?
      Rugged::Repository.new(pathname.to_s)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def branch(*args)
    Branch.find(rugged_repository, *args)
  end

  def commit(*args)
    Commit.find(rugged_repository, *args)
  end

  def create_branch(source_branch_name, target_branch_name)
    rugged_repository.branches.create(target_branch_name, source_branch_name)
  end

  def custom_branch_names
    rugged_repository.branches.each_name(:local).sort.reject do |name|
      name == 'master' || name.match(/\Astatic_user_\d+\z/)
    end
  end

  def delete_branch(name)
    rugged_repository.references.delete("refs/heads/#{name}")
  end

  def local_branch?(branch_name)
    rugged_repository.branches.each_name(:local).include?(branch_name)
  end

  def move_branch(old_name, new_name)
    rugged_repository.references.rename("refs/heads/#{old_name}", "refs/heads/#{new_name}")
  end

  def rugged_repository
    @rugged_repository ||= Repository.rugged_repository(website_id)
  end

  def setup?
    !rugged_repository.empty? && rugged_repository.branches['master']
  end
end

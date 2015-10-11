class Repository
  include ActiveModel::Model

  attr_accessor :website_id

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
      name == 'master' || name.match(/\Aswm_user_\d+\z/)
    end
  end

  def local_branch?(branch_name)
    rugged_repository.branches.each_name(:local).include?(branch_name)
  end

  def merge_base(*args)
    rugged_repository.merge_base(*args)
  end

  def repository_pathname
    if website_id.present?
      Rails.root.join(Rails.application.secrets.repos_dir, "#{website_id}.git")
    end
  end

  def rugged_repository
    return @rugged_repository if @rugged_repository

    if repository_pathname.present? && repository_pathname.exist?
      @rugged_repository ||= Rugged::Repository.new(repository_pathname.to_s)
    elsif repository_pathname.present?
      @rugged_repository ||= Rugged::Repository.init_at(repository_pathname.to_s, :bare)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def setup?
    !rugged_repository.empty? && rugged_repository.branches['master']
  end

  def update_ref(*args)
    rugged_repository.references.update(*args)
  end
end

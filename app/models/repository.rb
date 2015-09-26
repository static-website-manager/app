class Repository
  include ActiveModel::Model

  attr_accessor :website_id

  def custom_branch_names
    rugged_repository.branches.each_name(:local).sort.reject do |name|
      name == 'master' || name.match(/\Aswm_user_\d+\z/)
    end
  end

  def setup?
    !rugged_repository.empty? && rugged_repository.branches['master']
  end

  private

  def repository_pathname
    if website_id.present?
      Rails.root.join(Rails.application.secrets.repos_dir, "#{website_id}.git")
    end
  end

  def rugged_repository
    return @rugged_repository if @rugged_repository

    if repository_pathname.present? && repository_pathname.exist?
      @rugged_repository ||= Rugged::Repository.new(repository_pathname.to_s)
    elsif repository_pathname.exist?
      @rugged_repository ||= Rugged::Repository.init_at(repository_pathname.to_s, :bare)
    elsif website_id.present?
      raise ArgumentError, 'there was an unknown error'
    else
      raise ArgumentError, 'website_id must be set'
    end
  end
end

class Commit
  include ActiveModel::Model

  def self.find(rugged_repository, commit_id)
    rugged_commit = rugged_repository.lookup(commit_id)

    if rugged_commit
      Commit.new(
        author_email: rugged_commit.author[:email],
        author_name: rugged_commit.author[:name],
        id: rugged_commit.oid,
        message: rugged_commit.message,
        parent_ids: rugged_commit.parent_ids,
        rugged_commit: rugged_commit,
        rugged_repository: rugged_repository,
        time: rugged_commit.time,
      )
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def self.all(rugged_repository, commit_id, pathname: nil, page: 1, per_page: 20)
    commits = Rugged::Walker.new(rugged_repository).tap do |walker|
      walker.sorting Rugged::SORT_TOPO
      walker.push commit_id
    end
  
    if pathname.present?
      commits = commits.select do |rugged_commit|
        rugged_commit.diff(paths: [pathname]).size > 0
      end
    end
    
    commits = commits.map do |rugged_commit|
      Commit.new(
        author_email: rugged_commit.author[:email],
        author_name: rugged_commit.author[:name],
        id: rugged_commit.oid,
        message: rugged_commit.message,
        parent_ids: rugged_commit.parent_ids,
        rugged_commit: rugged_commit,
        rugged_repository: rugged_repository,
        time: rugged_commit.time,
      )
    end

    Kaminari.paginate_array(commits).page(page).per(per_page)
  end

  attr_accessor :author_email, :author_name, :id, :message, :parent_ids, :rugged_commit, :rugged_repository, :time

  def diff
    if rugged_commit.parents.any?
      Diff.new(rugged_commit.parents[0].diff(rugged_commit))
    else
      Diff.new(rugged_commit.diff)
    end
  end

  def persisted?
    id.present?
  end

  def short_id
    id[0..6]
  end

  def to_param
    id
  end
end

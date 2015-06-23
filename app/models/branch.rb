class Branch
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_reader :refname

  def initialize(repository, commit_id, refname)
    @repository = repository
    @commit_id = commit_id
    @refname = refname.split('/').last
  end

  def persisted?
    true
  end

  def to_param
    @refname
  end

  def pages
    `cd #{@repository.directory}; git ls-tree #@refname`.split("\n").map do |result|
      mode, type, id, name = result.split(' ')

      if name.to_s.match(/\A[a-zA-Z0-9]/)
        Page.new(id, type, mode, name)
      end
    end.compact
  end

  def drafts
    `cd #{@repository.directory}; git ls-tree #@refname _drafts/`.split("\n").map do |result|
      mode, type, commit_id, path = result.split(' ')

      if type.to_s == 'blob' && path.present?
        Post.new(commit_id, path.sub(/\A_drafts\//, ''))
      end
    end.compact
  end

  def posts
    `cd #{@repository.directory}; git ls-tree #@refname _posts/`.split("\n").map do |result|
      mode, type, commit_id, path = result.split(' ')

      if type.to_s == 'blob' && path.present?
        Post.new(commit_id, path.sub(/\A_posts\//, ''))
      end
    end.compact
  end
end

class Branch
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def self.find(rugged_repository, name_or_user)
    raw_name = name_or_user.is_a?(User) ? "swm_user_#{name_or_user.id}" : name_or_user.to_s
    rugged_branch = rugged_repository.branches[raw_name]
    if rugged_branch
      new(rugged_repository, rugged_branch)
    elsif name_or_user.is_a?(User)
      new(rugged_repository, rugged_repository.branches.create("swm_user_#{name_or_user.id}", 'master'))
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def initialize(rugged_repository, rugged_branch)
    @rugged_repository = rugged_repository
    @rugged_branch = rugged_branch
  end

  def commit
    Commit.new(@rugged_repository, @rugged_branch.target)
  end

  def commits(page: 1, per_page: 20)
    Kaminari.paginate_array(
      Rugged::Walker.new(@rugged_repository).tap do |walker|
        walker.sorting Rugged::SORT_TOPO
        walker.push @rugged_branch.target
      end.map do |rugged_commit|
        Commit.new(@rugged_repository, rugged_commit)
      end
    ).page(page).per(per_page)
  end

  def pages
    tree.pages
  end

  def pages
    tree.pages
  end

  def drafts
    tree.drafts
  end

  def posts(page: 1, per_page: 20)
    Kaminari.paginate_array(tree.posts).page(page).per(per_page)
  end

  def raw_name
    @rugged_branch.name
  end

  def name
    raw_name.match(/\Aswm_user_\d+\z/) ? 'working' : raw_name
  end

  def persisted?
    true
  end

  def to_param
    name
  end

  def tree
    @tree ||= Tree.new(@rugged_repository, @rugged_branch.target.tree)
  end
end

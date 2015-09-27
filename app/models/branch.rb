class Branch
  include ActiveModel::Model

  def self.find(rugged_repository, name_or_user)
    if name_or_user.blank?
      raise ActiveRecord::RecordNotFound
    elsif name_or_user.is_a?(User)
      name = "swm_user_#{name_or_user.id}"
    else
      name = name_or_user.to_s
    end

    rugged_branch = rugged_repository.branches[name]

    if rugged_branch
      new(
        name: name,
        rugged_repository: rugged_repository,
        rugged_branch: rugged_branch,
      )
    elsif name_or_user.is_a?(User)
      new(
        name: name,
        rugged_repository: rugged_repository,
        rugged_branch: rugged_repository.branches.create(name, 'master'),
      )
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  attr_accessor :name, :rugged_branch, :rugged_repository

  def short_id
    rugged_branch.target.oid[0..6]
  end

  def raw_name
    rugged_branch.name
  end

  def name
    raw_name.match(/\Aswm_user_\d+\z/) ? 'working' : raw_name
  end

  def full_name
    case name
    when 'master'
      'Master Branch'
    when 'working'
      'Your Working Branch'
    else
      "Custom Branch “#{name}”"
    end
  end

  def short_name
    case name
    when 'master'
      'Master Branch'
    when 'working'
      'Your Working Branch'
    else
      'Custom Branch'
    end
  end

  def basic_name
    case name
    when 'master'
      'Master Branch'
    when 'working'
      'Your Working Branch'
    else
      name
    end
  end

  def parents
    Rugged::Walker.new(@rugged_repository).tap do |walker|
      walker.push target
    end
  end

  def persisted?
    true
  end

  def target
    rugged_branch.target
  end

  def tree
    rugged_branch.target.tree
  end

  def to_param
    name
  end
end

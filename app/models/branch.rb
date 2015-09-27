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

  def commit_id
    rugged_branch.target.oid
  end

  def master?
    name == 'master'
  end

  def persisted?
    true
  end

  def short_id
    rugged_branch.target.oid[0..6]
  end

  def title(user)
    if master?
      'Master Branch'
    elsif working?(user)
      'Your Working Branch'
    else
      "Custom Branch “#{name}”"
    end
  end

  def to_param
    name
  end

  def working?(user)
    name == "swm_user_#{user.id}"
  end
end

class Branch
  include ActiveModel::Model

  attr_accessor :name, :rugged_branch, :rugged_repository

  def self.find(rugged_repository, website_id, name_or_user)
    if name_or_user.blank?
      raise ActiveRecord::RecordNotFound
    elsif name_or_user.is_a?(User)
      name = "static_user_#{name_or_user.id}"
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
      ).tap do |branch|
        website = Website.find_by_id(website_id)

        if website
          deployments = website.deployments.where(branch_name: name)

          if website.auto_deploy_staging?
            deployment = deployments.first_or_create
          else
            deployment = deployments.first
          end

          if deployment
            JekyllBuildJob.perform_later(deployment)
          end
        end
      end
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def self.html_extensions
    %w[htm html]
  end

  def self.markdown_extensions
    %w[markdown mdown mkdn mkd md]
  end

  def self.page_extensions
    html_extensions + markdown_extensions
  end

  def commit_id
    rugged_branch.target.oid
  end

  def html_extensions
    Branch.html_extensions
  end

  def layout_names
    rugged_repository.lookup(commit_id).tree.walk(:postorder).select do |root, object|
      root == '_layouts/'
    end.map do |root, object|
      object[:name].split('.').first
    end.reject(&:blank?).uniq
  end

  def markdown_extensions
    Branch.markdown_extensions
  end

  def page_extensions
    html_extensions + markdown_extensions
  end

  def production?
    name == 'master'
  end

  def persisted?
    true
  end

  def short_id
    rugged_branch.target.oid[0..6]
  end

  def staging?(user = nil)
    if user
      name == "static_user_#{user.id}"
    else
      name.match(/\Astatic_user_\d{1,9}\z/)
    end
  end

  def title(current_user)
    if production?
      'Production Branch'
    elsif staging?(current_user)
      'Your Staging Branch'
    elsif staging?
      "#{user.name}’s Staging Branch"
    else
      "Custom Branch: #{name}"
    end
  end

  def to_param
    name
  end

  def user
    User.find_by_id(name.match(/\Astatic_user_(\d{1,9})\z/)[1])
  end
end

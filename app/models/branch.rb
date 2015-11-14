require 'open3'

class Branch
  include ActiveModel::Model

  attr_accessor :name, :rugged_branch, :rugged_repository

  def self.find(rugged_repository, name_or_user, auto_create_staging: true)
    if name_or_user.is_a?(User)
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
    elsif auto_create_staging && name.match(/\Astatic_user_\d{1,9}\z/)
      new(
        name: name,
        rugged_repository: rugged_repository,
        rugged_branch: rugged_repository.create_branch(name, 'master'),
      )
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

  def commit
    Commit.find(rugged_repository, commit_id)
  end

  def commit_id
    rugged_branch.target.oid
  end

  def config
    config_content = nil

    result = rugged_repository.lookup(commit_id).tree.walk(:postorder).find do |root, object|
      object[:type] == :blob && File.join([root, object[:name]].reject(&:blank?)) == '_config.yml'
    end

    if result
      rugged_blob = rugged_repository.lookup(result[1][:oid])

      if rugged_blob
        config_content = rugged_blob.text
      end
    end

    Config.new(branch_name: name, raw_content: config_content, rugged_repository: rugged_repository)
  end

  def custom?
    !production? && !staging?
  end

  def diff(branch)
    Diff.new(
      page_extensions: page_extensions,
      rugged_diff: rugged_repository.lookup(branch.commit_id).diff(rugged_repository.lookup(commit_id)).tap(&:find_similar!),
    )
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

  def merge(branch, user_email, user_name, commit_message)
    raise ArgumentError unless branch.present?
    raise ArgumentError unless user_email.present?
    raise ArgumentError unless user_name.present?
    raise ArgumentError unless commit_message.present?
    raise ArgumentError unless merge_possible?(branch)
    merge_index = rugged_repository.merge_commits(commit_id, branch.commit_id)
    raise ArgumentError if merge_index.conflicts?

    commit_author = {
      email: user_email,
      name: user_name,
      time: Time.now,
    }

    begin
      merge_commit_id = Rugged::Commit.create(rugged_repository, {
        parents: [branch.commit_id, commit_id],
        tree: merge_index.write_tree(rugged_repository),
        message: commit_message,
        author: commit_author,
        committer: commit_author,
        update_ref: "refs/heads/#{branch.name}",
      })
      rugged_repository.references.update("refs/heads/#{name}", merge_commit_id)
    rescue
      merge_commit_id = nil
    end

    merge_commit_id.present?
  end

  def merge_base(branch)
    rugged_repository.merge_base(commit_id, branch.commit_id)
  end

  def merge_commits(branch)
    rugged_repository.merge_commits(commit_id, branch.commit_id)
  end

  def merge_possible?(branch)
    common_commit = merge_base(branch)
    commit_id != branch.commit_id && commit_id != common_commit && (common_commit == branch.commit_id || branch.commit.parent_ids[1] == common_commit)
  end

  def merge_potential?(branch)
    commit_id != branch.commit_id && merge_base(branch) != commit_id
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

  def rebase(branch)
    raise ArgumentError unless branch.present?
    raise ArgumentError unless rebase_required?(branch)

    clone_path = Pathname.new(File.join('/tmp', "clone_#{rand(1000)}_#{Time.now.to_i}"))

    FileUtils.rm_rf(clone_path)
    FileUtils.mkdir(clone_path)

    begin
      system("git clone #{rugged_repository.path} #{clone_path}") &&
      system("git config user.email \"support@staticwebsitemanager.com\"", chdir: clone_path.to_s) &&
      system("git config user.name \"Static Website Manager\"", chdir: clone_path.to_s) &&
      system("git checkout #{name}", chdir: clone_path.to_s) &&
      system("git rebase master", chdir: clone_path.to_s) &&
      system("git push origin #{name} -f", chdir: clone_path.to_s)
    rescue
      false
    ensure
      FileUtils.rm_rf(clone_path)
    end
  end

  def rebase_required?(branch)
    common_commit = merge_base(branch)
    commit_id != branch.commit_id && common_commit != branch.commit_id && !(common_commit == commit_id && branch.commit.parent_ids[1] == commit_id) && !(common_commit == branch.commit_id || branch.commit.parent_ids[1] == common_commit)
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

  def title(current_user = nil)
    if production?
      'Production Branch'
    elsif current_user && staging?(current_user)
      'Your Staging Branch'
    elsif staging?
      "#{user.name}’s Staging Branch"
    else
      "Custom Branch “#{name}”"
    end
  end

  def to_param
    name
  end

  def user
    @user ||= User.find_by_id(name.match(/\Astatic_user_(\d{1,9})\z/)[1])
  end
end

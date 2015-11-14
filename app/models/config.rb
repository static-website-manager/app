class Config
  include ActiveModel::Model
  include ActiveModel::Dirty

  attr_accessor :branch_name, :config, :raw_content, :rugged_repository

  define_attribute_methods :raw_content

  def initialize(*args)
    super
    yaml = YAML.load(raw_content.to_s)
    @config = yaml.kind_of?(Hash) ? yaml : {}
    clear_changes_information
  end

  def config=(value)
    current_config = (@config.try(:to_hash) || {}).clone
    proposed_config = (value.try(:to_hash) || {})

    proposed_config.each do |key, value|
      if value.blank?
        current_config.delete(key)
      else
        current_config[key] = value
      end
    end

    new_content = YAML.dump(current_config.to_hash)

    if @raw_content != new_content
      raw_content_will_change!
      @raw_content = new_content
    end

    @config = current_config
  end

  def save(author_email, author_name, commit_message)
    raise ArgumentError unless rugged_repository.present?
    raise ArgumentError unless branch_name.present?
    raise ArgumentError unless author_name.present?
    raise ArgumentError unless author_email.present?
    raise ArgumentError unless commit_message.present?

    clone_path = Pathname.new(File.join('/tmp', "clone_#{rand(1000)}_#{Time.now.to_i}"))

    FileUtils.rm_rf(clone_path)
    FileUtils.mkdir(clone_path)

    begin
      cloned_repository = Rugged::Repository.clone_at(rugged_repository.path.to_s, clone_path.to_s, checkout_branch: branch_name)
      cloned_branch = cloned_repository.branches[branch_name]
      cloned_index = cloned_repository.index
      cloned_index.read_tree(cloned_branch.target.tree)

      object_id = cloned_repository.write(raw_content, :blob)
      cloned_index.add(path: '_config.yml', oid: object_id, mode: 0100644)

      author = {
        email: author_email,
        name: author_name,
        time: Time.now,
      }

      Rugged::Commit.create(cloned_repository,
        author: author,
        committer: author,
        message: commit_message,
        parents: [cloned_branch.target],
        tree: cloned_index.write_tree(cloned_repository),
        update_ref: 'refs/heads/' + branch_name,
      )

      system("git push origin #{branch_name}", chdir: clone_path.to_s)
      changes_applied
      true
    rescue
      @raw_content = raw_content_was
      false
    ensure
      FileUtils.rm_rf(clone_path)
    end
  end

  def unchanged?
    !changed?
  end
end

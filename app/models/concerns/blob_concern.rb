module BlobConcern
  extend ActiveSupport::Concern
  include ActiveModel::Model
  include ActiveModel::Dirty

  attr_accessor :filename, :id, :pathname, :rugged_blob, :rugged_repository

  included do
    define_attribute_methods :filename, :id, :pathname
  end

  def basename
    filename.present? ? filename.split('.')[0..-2].join('.') : ''
  end

  def basepath
    File.join([pathname, basename].reject(&:blank?))
  end

  def destroy(*args)
    perform_git_operation(*args) do |cloned_repository, cloned_index|
      cloned_index.remove(full_pathname)
    end
  end

  def extension
    filename.present? && filename.split('.').length > 1 ? filename.split('.').last : ''
  end

  def filename=(value)
    if value.try(:to_s) == @filename
      @filename
    else
      filename_will_change!
      @filename = value.try(:to_s)
    end
  end

  def full_pathname
    File.join([pathname, filename].reject(&:blank?))
  end

  def full_pathname_was
    File.join([pathname_was, filename_was].reject(&:blank?))
  end

  def full_pathname=(value)
    self.pathname = value.to_s.split('/')[0..-2].join('/')
    self.filename = value.to_s.split('/').last
  end

  def id=(value)
    if value.try(:to_s) == @id
      @id
    else
      id_will_change!
      @id = value.try(:to_s)
    end
  end

  def initialize(*args)
    super
    clear_changes_information
  end

  def pathname=(value)
    if value.try(:to_s) == @pathname
      @pathname
    else
      pathname_will_change!
      @pathname = value.try(:to_s)
    end
  end

  def persisted?
    id.present?
  end

  def public_url(host)
    File.join([host, pathname, basename].reject(&:blank?)).to_s + '.html'
  end

  def raw_content
    rugged_blob.content.encode('utf-8', 'utf-8', invalid: :replace)
  end

  def raw_text
    rugged_blob.text.encode('utf-8', 'utf-8', invalid: :replace)
  end

  def save(*args)
    perform_git_operation(*args) do |cloned_repository, cloned_index|
      # valid?
      cloned_index.remove(full_pathname_was)
      self.id = cloned_repository.write(raw_content, :blob)
      cloned_index.add(path: full_pathname, oid: id, mode: 0100644)
    end
  end

  def short_id
    id[0..6]
  end

  def to_param
    if defined?(pretty_pathname)
      pretty_pathname
    else
      full_pathname
    end
  end

  def unchanged?
    !changed?
  end

  private

  def perform_git_operation(branch_name, author_email, author_name, commit_message, deployment = nil)
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

      yield(cloned_repository, cloned_index)

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

      if deployment
        JekyllBuildJob.perform_later(deployment)
      end

      changes_applied
      true
    rescue
      @filename = filename_was
      @id = id_was
      @pathname = pathname_was
      false
    ensure
      FileUtils.rm_rf(clone_path)
    end
  end
end

module BlobConcern
  extend ActiveSupport::Concern

  attr_accessor :filename, :id, :pathname, :rugged_blob, :rugged_repository

  def basename
    filename.present? ? filename.split('.')[0..-2].join('.') : ''
  end

  def destroy(branch_name, author_email, author_name, commit_message)
    clone_path = Rails.root.join('tmp', "clone_#{rand(1000)}_#{Time.now.to_i}")

    FileUtils.rm_rf(clone_path)
    FileUtils.mkdir(clone_path)

    begin
      cloned_repository = Rugged::Repository.clone_at(rugged_repository.path.to_s, clone_path.to_s)
      cloned_repository.checkout('origin/' + branch_name)
      cloned_branch = cloned_repository.branches['origin/' + branch_name]

      cloned_index = cloned_repository.index
      cloned_index.read_tree(cloned_branch.target.tree)
      cloned_index.remove(full_pathname)

      author = {
        email: author_email,
        name: author_name,
        time: Time.now,
      }

      Rugged::Commit.create(cloned_repository,
        author: author,
        committer: author,
        message: commit_message.present? ? commit_message : "Remove #{self.class.name}",
        parents: [cloned_branch.target],
        tree: cloned_index.write_tree(cloned_repository),
        update_ref: 'refs/heads/' + branch_name,
      )

      # rugged_repository.push('origin', [branch_name])

      `
        cd #{clone_path};
        git push origin #{branch_name};
      `
      true
    rescue
      # Cleanup git object?
      false
    ensure
      FileUtils.rm_rf(clone_path)
    end
  end

  def extension
    filename.present? && filename.split('.').length > 1 ? filename.split('.').last : ''
  end

  def full_pathname
    File.join([pathname, filename].reject(&:blank?))
  end

  def move(filename, branch_name, author_email, author_name, commit_message)
    original_filename = filename
    clone_path = Rails.root.join('tmp', "clone_#{rand(1000)}_#{Time.now.to_i}")

    FileUtils.rm_rf(clone_path)
    FileUtils.mkdir(clone_path)

    begin
      cloned_repository = Rugged::Repository.clone_at(rugged_repository.path.to_s, clone_path.to_s)
      cloned_repository.checkout('origin/' + branch_name)
      cloned_branch = cloned_repository.branches['origin/' + branch_name]

      cloned_index = cloned_repository.index
      cloned_index.read_tree(cloned_branch.target.tree)
      cloned_index.remove(full_pathname)

      @filename = filename
      # Check for validity?

      cloned_index.add(path: full_pathname, oid: id, mode: 0100644)

      author = {
        email: author_email,
        name: author_name,
        time: Time.now,
      }

      Rugged::Commit.create(cloned_repository,
        author: author,
        committer: author,
        message: commit_message.present? ? commit_message : "Move #{self.class.name}",
        parents: [cloned_branch.target],
        tree: cloned_index.write_tree(cloned_repository),
        update_ref: 'refs/heads/' + branch_name,
      )

      # rugged_repository.push('origin', [branch_name])

      `
        cd #{clone_path};
        git push origin #{branch_name};
      `
      true
    rescue
      @filename = original_filename
      # Cleanup git object?
      false
    ensure
      FileUtils.rm_rf(clone_path)
    end
  end

  def persisted?
    id.present?
  end

  def raw_content
    rugged_blob.content.force_encoding('utf-8')
  end

  def raw_text
    rugged_blob.text.force_encoding('utf-8')
  end

  def save(branch_name, author_email, author_name, commit_message)
    # Check for validity?
    original_id = id
    clone_path = Rails.root.join('tmp', "clone_#{rand(1000)}_#{Time.now.to_i}")

    FileUtils.rm_rf(clone_path)
    FileUtils.mkdir(clone_path)

    begin
      cloned_repository = Rugged::Repository.clone_at(rugged_repository.path.to_s, clone_path.to_s)
      cloned_repository.checkout('origin/' + branch_name)
      cloned_branch = cloned_repository.branches['origin/' + branch_name]

      @id = cloned_repository.write(raw_content, :blob)

      cloned_index = cloned_repository.index
      cloned_index.read_tree(cloned_branch.target.tree)
      cloned_index.add(path: full_pathname, oid: id, mode: 0100644)

      author = {
        email: author_email,
        name: author_name,
        time: Time.now,
      }

      Rugged::Commit.create(cloned_repository,
        author: author,
        committer: author,
        message: commit_message.present? ? commit_message : (original_id.present? ? "Save changes to #{pretty_pathname}" : "Add New #{self.class.name}"),
        parents: [cloned_branch.target],
        tree: cloned_index.write_tree(cloned_repository),
        update_ref: 'refs/heads/' + branch_name,
      )

      # rugged_repository.push('origin', [branch_name])

      `
        cd #{clone_path};
        git push origin #{branch_name};
      `
      true
    rescue
      @id = original_id
      # Cleanup git object?
      false
    ensure
      FileUtils.rm_rf(clone_path)
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
end

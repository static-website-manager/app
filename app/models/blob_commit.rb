class BlobCommit
  include ActiveModel::Model

  attr_reader :user, :website, :branch, :blob, :id

  def initialize(user, website, branch, blob)
    @user = user
    @website = website
    @branch = branch
    @blob = blob
  end

  def save(raw_content, commit_message)
    clone_path = Rails.root.join('tmp', "clone_#{rand(1000)}_#{Time.now.to_i}")

    FileUtils.rm_rf(clone_path)
    FileUtils.mkdir(clone_path)

    begin
      rugged_repository = Rugged::Repository.clone_at(website.repository_pathname.to_s, clone_path.to_s)
      rugged_repository.checkout('origin/' + branch.raw_name)
      rugged_branch = rugged_repository.branches['origin/' + branch.raw_name]

      @id = rugged_repository.write(raw_content, :blob)
      index = rugged_repository.index
      index.read_tree(rugged_branch.target.tree)
      index.add(path: blob.raw_pathname, oid: @id, mode: 0100644)

      author = {
        email: user.email,
        name: user.name,
        time: Time.now,
      }

      Rugged::Commit.create(rugged_repository,
        author: author,
        committer: author,
        message: commit_message.present? ? commit_message : "Save changes to #{blob.raw_pathname}",
        parents: [rugged_branch.target],
        tree: index.write_tree(rugged_repository),
        update_ref: 'refs/heads/' + branch.raw_name,
      )

      # rugged_repository.push('origin', [branch.raw_name])

      `
        cd #{clone_path};
        git push origin #{branch.raw_name};
      `
    rescue
      @id = nil
    ensure
      FileUtils.rm_rf(clone_path)
    end

    !!@id
  end
end

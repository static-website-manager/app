class Draft
  include ActiveModel::Model
  include BlobConcern
  include PageConcern

  def self.all(rugged_repository, commit_id)
    rugged_repository.lookup(commit_id).tree.walk(:postorder).select do |root, object|
      root.match(/\A_drafts/) && object[:name].match(/\A[\w\-]+\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/)
    end.map do |root, object|
      new(
        id: object[:oid],
        filename: object[:name],
        pathname: root,
        rugged_repository: rugged_repository,
      )
    end
  end

  def self.find(*args)
    super *args.push(/\A_drafts/)
  end

  def pretty_pathname
    full_pathname.gsub(/\A_drafts\//, '')
  end

  def publish(publication_date, branch_name, author_email, author_name, commit_message)
    original_pathname = pathname
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

      @pathname = '_posts/'
      @filename = [*original_filename.split('/')[0..-2], publication_date.strftime('%Y-%m-%d'), original_filename.split('/')[-1]].join('-')
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
        message: commit_message.present? ? commit_message : 'Publish Draft',
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
      @pathname = original_pathname
      @filename = original_filename
      # Cleanup git object?
      false
    ensure
      FileUtils.rm_rf(clone_path)
    end
  end

  def title
    filename.split('.').first.titleize
  end
end

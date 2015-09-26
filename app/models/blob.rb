class Blob
  include ActiveModel::Conversion

  attr_reader :name, :id, :mode, :type, :path

  def initialize(rugged_repository, name, id, mode, type, path)
    @rugged_repository = rugged_repository
    @name = name
    @id = id
    @mode = mode
    @type = type
    @path = path
  end

  def commits(target, page: 1, per_page: 20)
    Kaminari.paginate_array(
      Rugged::Walker.new(@rugged_repository).tap do |walker|
        walker.sorting Rugged::SORT_TOPO
        walker.push target
      end.select do |rugged_commit|
        rugged_commit.diff(paths: [raw_pathname]).size > 0
      end.map do |rugged_commit|
        Commit.new(@rugged_repository, rugged_commit)
      end
    ).page(page).per(per_page)
  end

  def raw_content
    rugged_blob.content
  end

  def content
    @content ||= rugged_blob.content.sub(metadata_regex, '').force_encoding('utf-8')
  end

  def metadata
    @metadata ||= rugged_blob.content.match(metadata_regex) ? Hash(YAML.load(rugged_blob.content)) : {}
  end

  def raw_pathname
    File.join([@path, @name].reject(&:blank?))
  end

  def persisted?
    true
  end

  def short_id
    id[0..6]
  end

  def update(changes)
    CommitService.update_file(changes.merge(path: raw_pathname))
  end

  def writable?
    @name.match(/\.(markdown|mdown|mkdn|mkd|md)\z/)
  end

  def save(website, branch, user, raw_content, commit_message)
    clone_path = Rails.root.join('tmp', "clone_#{rand(1000)}_#{Time.now.to_i}")

    FileUtils.rm_rf(clone_path)
    FileUtils.mkdir(clone_path)

    begin
      rugged_repository = Rugged::Repository.clone_at(website.repository_pathname.to_s, clone_path.to_s)
      rugged_repository.checkout('origin/' + branch.raw_name)
      rugged_branch = rugged_repository.branches['origin/' + branch.raw_name]

      new_id = rugged_repository.write(raw_content, :blob)
      index = rugged_repository.index
      index.read_tree(rugged_branch.target.tree)
      index.add(path: raw_pathname, oid: new_id, mode: 0100644)

      author = {
        email: user.email,
        name: user.name,
        time: Time.now,
      }

      Rugged::Commit.create(rugged_repository,
        author: author,
        committer: author,
        message: commit_message.present? ? commit_message : "Save changes to #{raw_pathname}",
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
      new_id = nil
      # Cleanup git object?
    ensure
      FileUtils.rm_rf(clone_path)
    end

    new_id
  end

  private

  def metadata_regex
    /\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m
  end

  def rugged_blob
    @rugged_blob ||= @rugged_repository.lookup(@id)
  end
end

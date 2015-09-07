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
        rugged_commit.parents.size == 1 && rugged_commit.diff(paths: [raw_pathname]).size > 0
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

  def update(changes)
    CommitService.update_file(changes.merge(path: raw_pathname))
  end

  def writable?
    @name.match(/\.(markdown|md)\z/)
  end

  private

  def metadata_regex
    /\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m
  end

  def rugged_blob
    @rugged_blob ||= @rugged_repository.lookup(@id)
  end
end

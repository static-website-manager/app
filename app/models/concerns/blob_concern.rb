module BlobConcern
  extend ActiveSupport::Concern
  include ActiveModel::Conversion

  attr_reader :name, :id, :mode, :type, :path

  def initialize(rugged_repository, name, id, mode, type, path)
    @rugged_repository = rugged_repository
    @name = name
    @path = "_posts/articles/#{name}"
    @id = id
    @mode = mode
    @type = type
    @path = path
  end

  def author
    'Theodore Kimble'
  end

  def commits(refspec)
    Rugged::Walker.new(@rugged_repository).tap do |walker|
      walker.sorting Rugged::SORT_TOPO
      walker.push refspec
    end.select do |rugged_commit|
      rugged_commit.parents.size == 1 && rugged_commit.diff(paths: [raw_pathname]).size > 0
    end.map do |rugged_commit|
      Commit.new(@rugged_repository, rugged_commit)
    end
  end

  def raw_pathname
    File.join([@path, @name].reject(&:blank?))
  end

  def persisted?
    true
  end

  def published_on
    1.week.ago
  end

  def writable?
    @name.match(/\.(markdown|md)\z/)
  end
end

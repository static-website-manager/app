class Draft
  include ActiveModel::Model
  include BlobConcern

  def self.all(rugged_repository, commit_id)
    rugged_repository.lookup(commit_id).tree.walk(:postorder).select do |root, object|
      root.match(/\A_drafts/) && object[:name].match(/\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/)
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

  def title
    filename.split('.').first.titleize
  end
end

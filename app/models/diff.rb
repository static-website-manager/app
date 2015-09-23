class Diff
  include ActiveModel::Model

  def initialize(rugged_diff)
    @rugged_diff = rugged_diff
  end

  def pages
    @rugged_diff.patches.select do |patch|
      patch.delta.new_file[:path].match(/\A[^_].+\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/)
    end
  end

  def drafts
    @rugged_diff.patches.select do |patch|
      patch.delta.new_file[:path].match(/\A_drafts\/.+\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/)
    end
  end

  def posts
    @rugged_diff.patches.select do |patch|
      patch.delta.new_file[:path].match(/\A_posts\/.+\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/)
    end
  end

  def files
    @rugged_diff.patches.select do |patch|
      !patch.delta.new_file[:path].match(/\A[^_].+\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/) &&
      !patch.delta.new_file[:path].match(/\A_drafts\/.+\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/) &&
      !patch.delta.new_file[:path].match(/\A_posts\/.+\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/)
    end
  end
end

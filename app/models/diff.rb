class Diff
  include ActiveModel::Model

  attr_accessor :rugged_diff

  def pages
    @pages ||= rugged_diff.patches.select do |patch|
      patch.delta.new_file[:path].match(/\A[^_].+\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/)
    end
  end

  def drafts
    @drafts ||= rugged_diff.patches.select do |patch|
      patch.delta.new_file[:path].match(/\A_drafts\/.+\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/)
    end
  end

  def posts
    @posts ||= rugged_diff.patches.select do |patch|
      patch.delta.new_file[:path].match(/\A_posts\/.+\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/)
    end
  end

  def files
    @files ||= rugged_diff.patches.select do |patch|
      !patch.delta.new_file[:path].match(/\A[^_].+\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/) &&
      !patch.delta.new_file[:path].match(/\A_drafts\/.+\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/) &&
      !patch.delta.new_file[:path].match(/\A_posts\/.+\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/)
    end
  end
end

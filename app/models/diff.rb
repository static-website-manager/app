class Diff
  include ActiveModel::Model

  attr_accessor :page_extensions, :rugged_diff

  def drafts
    @drafts ||= rugged_diff.patches.select do |patch|
      draft?(patch)
    end
  end

  def files
    @files ||= rugged_diff.patches.select do |patch|
      !page?(patch) && !draft?(patch) && !post?(patch)
    end
  end

  def pages
    @pages ||= rugged_diff.patches.select do |patch|
      page?(patch)
    end
  end

  def posts
    @posts ||= rugged_diff.patches.select do |patch|
      post?(patch)
    end
  end

  private

  def draft?(patch)
    patch.delta.new_file[:path].match(/\A_drafts\/.+\.(#{page_extensions.join('|')})\z/)
  end

  def page?(patch)
    patch.delta.new_file[:path].match(/\A[^_\.].+\.(#{page_extensions.join('|')})\z/)
  end

  def post?(patch)
    patch.delta.new_file[:path].match(/\A_posts\/.+\.(#{page_extensions.join('|')})\z/)
  end
end

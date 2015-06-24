class Rugged::BranchCollection
  def find(name)
    send(:[], name) or raise ActiveRecord::RecordNotFound
  end
end

class Rugged::Branch
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def model_name
    @_model_name ||= ActiveModel::Name.new(self, nil, 'branch')
  end

  def persisted?
    true
  end

  def to_param
    name
  end
end

class Rugged::Branch
  def drafts_tree_oid
    target.tree['_drafts'].try(:[], :oid)
  end

  def drafts
    if drafts_tree_oid.present?
      target.tree.repo.lookup(drafts_tree_oid).map do |object|
        Post.new(target.tree.repo, *object.values)
      end
    else
      []
    end
  end

  def posts_tree_oid
    target.tree['_posts'].try(:[], :oid)
  end

  def posts
    if posts_tree_oid.present?
      target.tree.repo.lookup(posts_tree_oid).map do |object|
        Post.new(target.tree.repo, *object.values)
      end
    else
      []
    end
  end

  def pages
    target.tree.map do |object|
      Page.new(target.tree.repo, *object.values) unless object[:name].match(/\A_/)
    end.compact
  end
end

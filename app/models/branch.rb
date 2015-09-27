class Branch
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def self.find(rugged_repository, name_or_user)
    raise ActiveRecord::RecordNotFound if name_or_user.blank?
    raw_name = name_or_user.is_a?(User) ? "swm_user_#{name_or_user.id}" : name_or_user.to_s
    rugged_branch = rugged_repository.branches[raw_name]
    if rugged_branch
      new(rugged_repository, rugged_branch)
    elsif name_or_user.is_a?(User)
      new(rugged_repository, rugged_repository.branches.create("swm_user_#{name_or_user.id}", 'master'))
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def initialize(rugged_repository, rugged_branch)
    @rugged_repository = rugged_repository
    @rugged_branch = rugged_branch
  end

  def short_id
    @rugged_branch.target.oid[0..6]
  end

  def find_blob(blob_class, oid)
    object = target.tree.walk(:postorder).find do |root, object|
      if object[:oid] == oid
        object[:root] = root
      end
    end

    if object
      if object[1][:root].match(/\A_drafts/)
        Draft.new(
          id: object[1][:oid],
          filename: object[1][:name],
          pathname: object[1][:root],
          rugged_repository: @rugged_repository,
        )
      elsif object[1][:root].match(/\A_posts/)
        Post.new(
          id: object[1][:oid],
          filename: object[1][:name],
          pathname: object[1][:root],
          rugged_repository: @rugged_repository,
        )
      else
        Page.new(
          id: object[1][:oid],
          filename: object[1][:name],
          pathname: object[1][:root],
          rugged_repository: @rugged_repository,
        )
      end
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def find_page(oid)
    find_blob(Page, oid)
  end

  def find_draft(oid)
    find_blob(Draft, oid)
  end

  def find_post(oid)
    find_blob(Post, oid)
  end

  def pages
    hash = {}

    target.tree.walk(:postorder).select do |root, object|
      !root.match(/\A_/) && (object[:type] == :tree || object[:name].match(/\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/))
    end.each do |root, object|
      (hash[root] ||= []) << object
    end

    def arrange(hash, root)
      trees = Array(hash[root]).select do |object|
        object[:type] == :tree
      end.map do |object|
        PageTree.new(filename: object[:name])
      end.sort_by(&:filename)

      blobs = Array(hash[root]).select do |object|
        object[:type] == :blob
      end.map do |object|
        Page.new(
          id: object[:oid],
          filename: object[:name],
          pathname: root,
          rugged_repository: @rugged_repository,
        )
      end.sort_by(&:filename).sort do |blob|
        blob.filename.match(/\Aindex\./) ? 0 : 1
      end

      trees.each do |tree|
        tree.objects = arrange(hash, root + tree.filename + '/')
      end

      blobs + trees.reject { |t| t.objects.empty? }
    end

    collection = arrange(hash, '')

    if root = collection.find { |object| object.is_a?(Page) && object.filename.match(/\Aindex\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/) }
      collection.delete(root)
      root.objects = collection
      collection = [root]
    end

    def extract(collection)
      collection.map do |object|
        if root = (object.objects || []).find { |o| o.is_a?(Page) && o.filename.match(/\Aindex\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/) }
          object.objects.delete(root)
          root.objects = extract(object.objects || [])
          root.dirname = object.filename
          root
        else
          object.objects = extract(object.objects || [])
          object
        end
      end
    end

    extract collection
  end

  def drafts
    target.tree.walk(:postorder).select do |root, object|
      root.match(/\A_drafts/) && object[:name].match(/\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/)
    end.map do |root, object|
      Draft.new(
        id: object[:oid],
        filename: object[:name],
        pathname: root,
        rugged_repository: @rugged_repository,
      )
    end
  end

  def posts(page: 1, per_page: 20)
    Kaminari.paginate_array(
      target.tree.walk(:postorder).select do |root, object|
        root.match(/\A_posts/) && object[:name].match(/\.(htm|html|text|txt|markdown|mdown|mkdn|mkd|md)\z/)
      end.map do |root, object|
        Post.new(
          id: object[:oid],
          filename: object[:name],
          pathname: root,
          rugged_repository: @rugged_repository,
        )
      end.sort_by(&:published_on).reverse
    ).page(page).per(per_page)
  end

  def raw_name
    @rugged_branch.name
  end

  def name
    raw_name.match(/\Aswm_user_\d+\z/) ? 'working' : raw_name
  end

  def full_name
    case name
    when 'master'
      'Master Branch'
    when 'working'
      'Your Working Branch'
    else
      "Custom Branch “#{name}”"
    end
  end

  def short_name
    case name
    when 'master'
      'Master Branch'
    when 'working'
      'Your Working Branch'
    else
      'Custom Branch'
    end
  end

  def basic_name
    case name
    when 'master'
      'Master Branch'
    when 'working'
      'Your Working Branch'
    else
      name
    end
  end

  def parents
    Rugged::Walker.new(@rugged_repository).tap do |walker|
      walker.push target
    end
  end

  def persisted?
    true
  end

  def target
    @rugged_branch.target
  end

  def to_param
    name
  end
end

class Dataset
  include ActiveModel::Model

  attr_accessor :content, :filename, :id, :pathname, :rugged_repository

  def self.all(rugged_repository, commit_id, page: 1, per_page: 20)
    Kaminari.paginate_array(
      rugged_repository.lookup(commit_id).tree.walk(:postorder).map do |root, object|
        if root.match(/\A_data/) && object[:name].match(/\A[\w\-]+\.(csv|json|yaml|yml)\z/)
          rugged_blob = rugged_repository.lookup(object[:oid])
          if rugged_blob && !rugged_blob.binary?
            new(
              content: rugged_blob.text,
              filename: object[:name],
              id: object[:oid],
              pathname: root,
              rugged_repository: rugged_repository,
            )
          end
        end
      end.compact
    ).page(page).per(per_page)
  end

  def self.find(rugged_repository, commit_id, pathname)
    result = rugged_repository.lookup(commit_id).tree.walk(:postorder).find do |root, object|
      File.join([root, object[:name]].reject(&:blank?)).sub(/\A_data\//, '') == pathname
    end

    if !result
      raise ActiveRecord::RecordNotFound
    elsif !result[0].match(/\A_data/)
      raise ActiveRecord::RecordNotFound
    elsif !result[1][:name].match(/\A[\w\-]+\.(csv|json|yaml|yml)\z/)
      raise ActiveRecord::RecordNotFound
    else
      rugged_blob = rugged_repository.lookup(result[1][:oid])

      if rugged_blob.binary?
        raise ActiveRecord::RecordNotFound
      else
        new(
          content: rugged_blob.text,
          filename: result[1][:name],
          id: result[1][:oid],
          pathname: result[0],
          rugged_repository: rugged_repository,
        )
      end
    end
  end

  def full_pathname
    File.join([pathname, filename].reject(&:blank?))
  end

  def persisted?
    id.present?
  end

  def pretty_pathname
    full_pathname.gsub(/\A_data\//, '')
  end

  def to_param
    pretty_pathname
  end
end

class Dataset
  include BlobConcern

  attr_accessor :content

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

  def append_data(data, *args)
    current_content = load_content

    if current_content && current_content.kind_of?(Array)
      self.content = dump_content([*current_content, data.to_hash])
      save(*args)
    end
  end

  def pretty_pathname
    full_pathname.gsub(/\A_data\//, '')
  end

  def raw_content
    content
  end

  def to_param
    pretty_pathname
  end

  def update_data(key, data, *args)
    current_content = load_content

    if current_content && current_content.kind_of?(Hash)
      self.content = dump_content(current_content.deep_merge(key.split('/').reverse.inject(data.to_hash) { |a, n| { n => a }}).to_hash)
      save(*args)
    end
  end

  private

  def dump_content(data)
    case extension
    when 'csv'
      CSV.generate do |csv|
        csv << CSV.parse(content)[0]

        data.each do |datum|
          csv << datum
        end
      end
    when 'json'
      JSON.dump(data)
    when *%w[yaml yml]
      YAML.dump(data)
    end
  end

  def load_content
    case extension
    when 'csv'
      CSV.parse(content)[1..-1] rescue nil
    when 'json'
      JSON.load(content) rescue nil
    when *%w[yaml yml]
      YAML.load(content) rescue nil
    end
  end
end

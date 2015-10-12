module PageConcern
  extend ActiveSupport::Concern

  attr_accessor :content, :metadata

  class_methods do
    def content(rugged_blob)
      rugged_blob.content.sub(/\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m, '').force_encoding('utf-8')
    end

    def find(rugged_repository, commit_id, id, match_pattern = nil)
      result = rugged_repository.lookup(commit_id).tree.walk(:postorder).find do |root, object|
        object[:name] == id
      end

      if result && (match_pattern ? result[0].match(match_pattern) : result[0])
        rugged_blob = rugged_repository.lookup(result[1][:oid])
        new(
          content: content(rugged_blob),
          id: result[1][:oid],
          filename: result[1][:name],
          metadata: metadata(rugged_blob),
          pathname: result[0],
          rugged_blob: rugged_blob,
          rugged_repository: rugged_repository,
        )
      else
        raise ActiveRecord::RecordNotFound
      end
    end

    def metadata(rugged_blob)
      rugged_blob.content.match(/\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m) ? Hash(YAML.load(rugged_blob.content)) : {}
    end
  end

  def raw_content
    if metadata.kind_of?(Hash) && metadata.any?
      [YAML.dump(metadata.to_hash), content].join("---\n\n")
    else
      "---\n---\n\n#{content}"
    end
  end

  def writable?
    filename.match(/\.(markdown|mdown|mkdn|mkd|md)\z/)
  end
end

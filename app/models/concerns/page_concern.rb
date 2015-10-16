module PageConcern
  extend ActiveSupport::Concern

  attr_accessor :content, :metadata

  class_methods do
    def content(rugged_blob)
      rugged_blob.content.sub(/\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m, '').force_encoding('utf-8')
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

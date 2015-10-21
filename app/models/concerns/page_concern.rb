module PageConcern
  extend ActiveSupport::Concern

  attr_accessor :content, :metadata

  class_methods do
    def content(rugged_blob)
      rugged_blob.text.sub(FRONT_MATTER_REGEXP, '').force_encoding('utf-8')
    end

    def metadata(rugged_blob)
      rugged_blob.text.match(FRONT_MATTER_REGEXP) ? Hash(YAML.load(rugged_blob.text)) : {}
    end
  end

  def excerpt
    if content.to_s.match("\n\n")
      content.to_s.split("\n\n").first
    else
      content.to_s.split("\r\n\r\n").first
    end
  end

  def markdown?(markdown_extensions)
    extension.match(/\A(#{markdown_extensions.join('|')})\z/)
  end

  def raw_content
    if metadata.kind_of?(Hash) && metadata.any?
      cleaned_metadata = metadata['permalink'].blank?, metadata.merge(permalink: nil) : metadata
      [YAML.dump(cleaned_metadata.to_hash), content].join("---\n\n")
    else
      "---\n---\n\n#{content}"
    end
  end
end

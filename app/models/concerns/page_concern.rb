module PageConcern
  extend ActiveSupport::Concern

  attr_accessor :content, :metadata

  included do
    define_attribute_methods :content, :metadata
  end

  class_methods do
    def content(rugged_blob)
      rugged_blob.text.sub(FRONT_MATTER_REGEXP, '').force_encoding('utf-8')
    end

    def metadata(rugged_blob)
      rugged_blob.text.match(FRONT_MATTER_REGEXP) ? Hash(YAML.load(rugged_blob.text)) : {}
    end
  end

  def content=(value)
    if value.try(:to_s) == @content
      @content
    else
      content_will_change!
      @content = value.try(:to_s)
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

  def metadata=(value)
    hashed_value = value.try(:to_hash)

    if hashed_value == @metadata
      @metadata
    elsif hashed_value
      metadata_will_change!
      @metadata = (@metadata || {}).merge(hashed_value)
    end
  end

  def raw_content
    if metadata.kind_of?(Hash) && metadata.any?
      cleaned_metadata = {}

      metadata.each do |key, value|
        if value.present?
          cleaned_metadata[key] = value
        end
      end

      [YAML.dump(cleaned_metadata.to_hash), content].join("---\n\n")
    else
      "---\n---\n\n#{content}"
    end
  end
end

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
    # Ensure no carriage returns are used.
    value = value.try(:to_s).gsub(/\r\n/, "\n")

    if value == @content
      @content
    else
      content_will_change!
      @content = value
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
    # TODO: Ensure no carriage returns are used.
    current_metadata = (@metadata.try(:to_hash) || {}).clone
    proposed_metadata = (value.try(:to_hash) || {})

    proposed_metadata.each do |key, value|
      if value.blank?
        current_metadata.delete(key)
      else
        current_metadata[key] = value
      end
    end

    if current_metadata == @metadata
      @metadata
    else
      metadata_will_change!
      @metadata = current_metadata
    end
  end

  def public_path
    File.join([(defined?(pretty_pathname) ? pretty_pathname : pathname), basename].reject(&:blank?)).to_s + '.html'
  end

  def public_url(host)
    File.join([host, (defined?(pretty_pathname) ? pretty_pathname : pathname), basename].reject(&:blank?)).to_s + '.html'
  end

  def raw_content
    if metadata.kind_of?(Hash) && metadata.any?
      [YAML.dump(metadata.to_hash), content].join("---\n\n")
    else
      "---\n---\n\n#{content}"
    end
  end
end

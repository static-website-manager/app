module ApplicationHelper
  def description(*args)
    content_for(:description, *args)
  end

  def errors_for(*models)
    render partial: 'application/errors', locals: { messages:  models.map(&:errors).map(&:full_messages).flatten }
  end

  def icor(*args)
    (args[0] + ' ' + icon(*args[1..-1])).html_safe
  end

  def layout(name, locals = {}, &block)
    render(layout: 'layouts/' + name.to_s, locals: locals, &block)
  end

  def markdown(html)
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(html)
  end

  def raw_sanitize(html)
    Sanitize.fragment(html, Sanitize::Config::RELAXED.deep_merge(
      attributes: { all: %w[dir hidden lang tabindex title translate], },
      protocols: { 'img' => { 'src' => ['http', 'https'] }},
    )).html_safe
  end

  def sanitize(html)
    fragment = Nokogiri::HTML.fragment(raw_sanitize(html))

    fragment.css('p').each do |node|
      if node.content.empty? && node.children.all? { |n| n.attributes.empty? }
        node.remove
      end
    end

    if fragment.to_s.present?
      fragment.to_s.html_safe
    else
      nil
    end
  end

  def title(locals = {})
    content_for(:title, t('.title', locals))
  end
end

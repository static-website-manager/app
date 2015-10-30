module ApplicationHelper
  def description(*args)
    content_for(:description, *args)
  end

  def errors_for(*models)
    render partial: 'application/errors', locals: { messages:  models.map(&:errors).map(&:full_messages).flatten }
  end

  def layout(name, locals = {}, &block)
    render(layout: 'layouts/' + name.to_s, locals: locals, &block)
  end

  def title(locals = {})
    content_for(:title, t('.title', locals))
  end
end

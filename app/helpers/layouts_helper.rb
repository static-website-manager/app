module LayoutsHelper
  def layout(name, locals = {}, &block)
    render(layout: 'layouts/' + name.to_s, locals: locals, &block)
  end
end

module LayoutHelper
  def title(locals = {})
    content_for(:title, t('.title', locals))
  end

  def description(*args)
    content_for(:description, *args)
  end
end

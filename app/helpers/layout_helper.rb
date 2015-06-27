module LayoutHelper
  def title(*args)
    content_for(:title, *args)
  end

  def description(*args)
    content_for(:description, *args)
  end
end

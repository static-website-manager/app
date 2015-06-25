module ErrorsHelper
  def errors_for(*models)
    render partial: 'application/errors', locals: { messages:  models.map(&:errors).map(&:full_messages).flatten }
  end
end

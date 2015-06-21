class Repository
  def initialize(id)
    raise ArgumentError, 'id must be a string' unless id.is_a?(String)
    raise ArgumentError, 'id must be present' unless id.present?
    @id = id
  end

  def initialized?
    false
  end

  def setup?
    false
  end
end

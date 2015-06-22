class Repository
  def initialize(id)
    raise ArgumentError, 'id must be a string' unless id.is_a?(String)
    raise ArgumentError, 'id must be present' unless id.present?
    @id = id
    init! unless directory.exist?
  end

  def directory
    Rails.root.join('repos', "#@id.git")
  end

  def branch(name)
    directory.join('refs', 'heads', name.to_s)
  end

  def branch?(*args)
    branch(*args).exist?
  end

  private

  def init!
    `git init --bare #{directory}`
  end
end

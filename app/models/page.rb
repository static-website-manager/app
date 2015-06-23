class Page
  include ActiveModel::Conversion

  attr_reader :filename

  def initialize(commit_id, type, mode, filename)
    @commit_id = commit_id
    @type = type
    @mode = mode
    @filename = filename + ('/' if type == 'tree').to_s
  end
end

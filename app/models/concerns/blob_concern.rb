module BlobConcern
  extend ActiveSupport::Concern
  include ActiveModel::Conversion

  attr_reader :name, :id, :mode, :type

  def initialize(rugged_repository, name, id, mode, type)
    @rugged_repository = rugged_repository
    @name = name
    @id = id
    @mode = mode
    @type = type
  end

  def persisted?
    true
  end
end

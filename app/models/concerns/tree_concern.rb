module TreeConcern
  extend ActiveSupport::Concern
  include ActiveModel::Conversion

  attr_reader :name, :id, :type
  attr_accessor :objects

  def initialize(rugged_repository, name, id, mode, type)
    @rugged_repository = rugged_repository
    @name = name
    @id = id
    @mode = mode
    @type = type
    @objects = []
  end
end

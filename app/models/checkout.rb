class Checkout
  include ActiveModel::Model

  class << self
    def i18n_scope
      :activerecord
    end
  end

  attr_accessor :user, :website, :source, :target

  validates :source, presence: true
  validates :target, presence: true, format: { without: /\A(swm_user|master)/ }
  validates :website, presence: true
  validates :user, presence: true

  validate do
    unless @website.rugged_repository.branches.each_name(:local).include?(source)
      errors.add :source, 'must already exist'
    end
  end

  validate do
    if @website.rugged_repository.branches.each_name(:local).include?(target)
      errors.add :target, 'must be unique'
    end
  end

  def save
    if valid?
      @website.rugged_repository.branches.create(target, source)
    end
  end
end

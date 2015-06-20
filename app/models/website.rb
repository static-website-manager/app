class Website < ActiveRecord::Base
  has_many :authorizations, dependent: :destroy

  validates :name, presence: true
  validates :parameterized_name, presence: true, uniqueness: { case_sensitive: false }
  validates :subscription_key, presence: true, uniqueness: { case_sensitive: false }

  before_validation do
    self.parameterized_name = name.parameterize if !parameterized_name? && name?
    self.subscription_key = SecureRandom.uuid if !subscription_key?
  end
end

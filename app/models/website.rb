class Website < ActiveRecord::Base
  has_many :authorizations, dependent: :destroy

  validates :name, presence: true
  validates :parameterized_name, presence: true, uniqueness: { case_sensitive: false }
  validates :subscription_key, presence: true, uniqueness: { case_sensitive: false }
end

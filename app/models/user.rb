class User < ActiveRecord::Base
  has_many :authorizations, dependent: :destroy

  validates :email, presence: true
end

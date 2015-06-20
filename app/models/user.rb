class User < ActiveRecord::Base
  has_many :authorizations, dependent: :destroy

  has_secure_password

  validates :email, presence: true
  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :password_confirmation, presence: true, if: -> { password.present? }
end

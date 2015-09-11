class User < ActiveRecord::Base
  has_many :authorizations, dependent: :destroy
  has_many :websites, through: :authorizations

  has_secure_password

  validates :email, presence: true, format: { with: /\A[^@]+@[^@]+\.[^@]+\z/ }
  validates :email_confirmation_token, uniqueness: true, allow_blank: true
  validates :name, presence: true
  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :password_confirmation, presence: true, if: -> { password.present? }
  validates :password_reset_token, uniqueness: true, allow_blank: true
  validates :session_token, uniqueness: true, allow_blank: true

  def email=(value)
    write_attribute(:email, value.to_s.downcase)
  end

  def email_confirmation_token!
    email_confirmation_token || generate_token!(:email_confirmation_token)
  end

  def password_reset_token!
    password_reset_token || generate_token!(:password_reset_token)
  end

  def session_token!
    session_token || generate_token!(:session_token)
  end

  private

  def generate_token!(name)
    SecureRandom.urlsafe_base64.tap do |token|
      update_column name, token
    end
  end
end

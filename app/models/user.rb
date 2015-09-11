class User < ActiveRecord::Base
  has_many :authorizations, dependent: :destroy
  has_many :websites, through: :authorizations

  has_secure_password

  validates :email, presence: true, format: { with: /\A[^@]+@[^@]+\.[^@]+\z/ }
  validates :name, presence: true
  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :password_confirmation, presence: true, if: -> { password.present? }

  def email=(value)
    write_attribute(:email, value.to_s.downcase)
  end

  def session_token!
    session_token || generate_token!(:session_token)
  end

  private

  def generate_token!(name)
    SecureRandom.urlsafe_base64.tap do |token|
      update_column :session_token, token
    end
  end
end

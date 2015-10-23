class Authentication < ActiveRecord::Base
  belongs_to :user

  validates :public_key, presence: true
  validates :user, presence: true
end

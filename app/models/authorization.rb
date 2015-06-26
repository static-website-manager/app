class Authorization < ActiveRecord::Base
  belongs_to :user
  belongs_to :website

  enum role: {
    full_access: 0,
  }

  accepts_nested_attributes_for :user, reject_if: :all_blank

  validates :role, presence: true, uniqueness: { scope: [:user, :website] }
  validates :user, presence: true
  validates :website, presence: true
end

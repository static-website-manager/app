class Authorization < ActiveRecord::Base
  belongs_to :user
  belongs_to :website

  enum role: {
    designer: 0,
    editor: 1,
    writer: 2,
  }

  accepts_nested_attributes_for :user, reject_if: :all_blank

  validates :role, presence: true, uniqueness: { scope: [:user, :website] }
  validates :user, presence: true
  validates :website, presence: true
end

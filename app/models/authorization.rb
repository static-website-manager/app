class Authorization < ActiveRecord::Base
  belongs_to :user
  belongs_to :website

  enum content_role: {
    designer: 0,
    editor: 1,
    writer: 2,
  }

  accepts_nested_attributes_for :user, reject_if: :all_blank

  validates :content_role, presence: true
  validates :user, presence: true, uniqueness: { scope: :website }
  validates :website, presence: true
end

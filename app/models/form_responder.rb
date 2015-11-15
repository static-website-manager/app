class FormResponder < ActiveRecord::Base
  belongs_to :website, touch: true

  validates :branch_name, presence: true
  validates :dataset_pathname, presence: true
  validates :path_id, presence: true, uniqueness: { case_sensitive: false }

  before_validation on: :create do
    loop do
      if path_id? && FormResponder.where(path_id: path_id).none?
        break true
      else
        self.path_id = SecureRandom.hex(4)
      end
    end
  end

  def self.active
    where(active: true)
  end
end

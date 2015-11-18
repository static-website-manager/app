class FormResponder < ActiveRecord::Base
  belongs_to :website, touch: true

  validates :branch_name, presence: true
  validates :path_id, presence: true, uniqueness: { case_sensitive: false }

  validate do
    if email_address_array.empty? && dataset_pathname.blank?
      errors.add(:email_addresses, :blank)
    elsif email_address_array.any? { |e| !e.match(/\A[^@]+@[^@]+\.[^@]+\z/) }
      errors.add(:email_addresses, :invalid)
    elsif email_address_array.length > 10
      errors.add(:email_addresses, :too_long, count: 10)
    end
  end

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

  def append_data(*args)
    dataset.append_data(*args, branch_name, "support@#{ENV['HOST']}", 'Static Website Manager', "Form Responder Update (#{path_id} => #{dataset_pathname})")
  end

  def email_address_array
    Array(email_addresses).reject(&:blank?)
  end

  def update_data(*args)
    dataset.update_data(*args, branch_name, "support@#{ENV['HOST']}", 'Static Website Manager', "Form Responder Update (#{path_id} => #{dataset_pathname})")
  end

  private

  def branch
    @branch ||= repository.branch(branch_name)
  end

  def dataset
    @dataset ||= Dataset.find(repository.rugged_repository, branch.commit_id, dataset_pathname)
  end

  def repository
    @repository ||= Repository.new(website_id: website_id)
  end
end

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

  def append_data(*args)
    dataset.append_data(*args, branch_name, "support@#{ENV['HOST']}", 'Static Website Manager', "Form Responder Update (#{path_id} => #{dataset_pathname})")
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

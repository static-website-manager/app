class Website < ActiveRecord::Base
  has_many :authorizations, dependent: :destroy
  has_many :users, through: :authorizations

  has_many :deployments, dependent: :destroy

  enum subscription_plan: {
    small: 0,
    medium: 1,
    large: 2,
  }

  enum subscription_status: {
    trialing: 0,
    active: 1,
    past_due: 2,
    canceled: 3,
    unpaid: 4,
  }

  validates :name, presence: true
  validates :subscription_plan, presence: true
  validates :subscription_status, presence: true

  after_create do
    begin
      setup!
    rescue Exception => e
      teardown!
      raise e
    end
  end

  after_destroy :teardown!

  def account_owners
    users.where(authorizations: { account_owner: true })
  end

  def repository_pathname
    @rugged_pathname ||= Repository.pathname(id)
  end

  def rugged_repository
    @rugged_repository ||= Repository.rugged_repository(id)
  end

  def update_post_receive!
    File.open(repository_pathname.join('hooks/post-receive').to_s, 'w+', 0755) do |file|
      file.write File.read(Rails.root.join('lib/post_receive.rb').to_s).sub(/WEBSITE_ID/, id.to_s).sub(/GIT_HOOK_TOKEN/, ENV['GIT_HOOK_TOKEN'])
    end
  end

  private

  def setup!
    Rugged::Repository.init_at(repository_pathname.to_s, :bare)
    update_post_receive!
  end

  def teardown!
    FileUtils.rm_rf(repository_pathname.to_s)
  end
end

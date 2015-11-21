class Website < ActiveRecord::Base
  has_many :authorizations, dependent: :destroy
  has_many :users, through: :authorizations

  has_many :deployments, dependent: :destroy
  has_many :form_responders, dependent: :destroy

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

  with_options on: :payment_information do
    validates :stripe_customer_token, presence: true
    validates :stripe_subscription_token, presence: true
  end

  validate do
    if authorizations.count > allowed_users
      errors.add(:subscription_plan, :users_exceeded, user_count: authorizations.count)
    end
  end

  after_create do
    begin
      setup!
    rescue Exception => e
      teardown!
      raise e
    end
  end

  after_destroy :teardown!

  def self.bucket_allotment
    small.count * 6 + medium.count * 14 + large.count * 27
  end

  def self.bucket_limit
    100
  end

  def self.requires_waiting_list?
    bucket_allotment + 27 > bucket_limit
  end

  def account_owners
    users.where(authorizations: { account_owner: true })
  end

  def allowed_users
    case subscription_plan
    when 'small'
      3
    when 'medium'
      8
    when 'large'
      16
    else
      0
    end
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

  def update_stripe(subscription_settings)
    ActiveRecord::Base.transaction do
      begin
        assign_attributes(subscription_settings)
        stripe_customer = Stripe::Customer.retrieve(stripe_customer_token)
        stripe_subscription = stripe_customer.subscriptions.retrieve(stripe_subscription_token)

        if save(context: :payment_information) && errors.empty?
          stripe_subscription.plan = [subscription_plan, yearly_billing? ? 'yearly' : 'monthly'].join('_')
          stripe_subscription.save
        else
          raise ActiveRecord::Rollback
        end
      rescue
        raise ActiveRecord::Rollback
      end
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

class Deployment < ActiveRecord::Base
  belongs_to :website

  validates :website, presence: true
  validates :branch_name, presence: true, uniqueness: { scope: :website_id }
  validates :host_prefix, presence: true, uniqueness: { case_sensitive: false }

  before_validation on: :create do
    loop do
      if valid_host_prefix?
        break true
      else
        self.host_prefix = SecureRandom.hex(4)
      end
    end
  end

  def url
    "http://#{host_prefix}.staticwebsitemanager.s3.amazonaws.com/"
  end

  private

  def valid_host_prefix?
    host_prefix? && Deployment.where(host_prefix: host_prefix).none?
  end
end

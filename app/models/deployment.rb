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

  after_create do
    begin
      setup!
    rescue Exception => e
      cleanup!
      raise e
    end
  end

  after_destroy :cleanup!

  def logging_bucket_name
    "#{host_prefix}.logs.staticwebsitemanager"
  end

  def url
    "http://#{website_bucket_name}.s3-website-us-west-2.amazonaws.com/"
  end

  def website_bucket_name
    "#{host_prefix}.staticwebsitemanager"
  end

  private

  def cleanup!
    Aws::S3::Bucket.new(logging_bucket_name).tap do |bucket|
      if bucket.exists?
        bucket.clear!
        bucket.delete
      end
    end
    Aws::S3::Bucket.new(website_bucket_name).tap do |bucket|
      if bucket.exists?
        bucket.clear!
        bucket.delete
      end
    end
  end

  def setup!
    Aws::S3::Client.new.tap do |client|
      client.create_bucket({
        acl: 'private',
        bucket: logging_bucket_name,
      })
      client.create_bucket({
        acl: 'private',
        bucket: website_bucket_name,
      })
      #client.put_bucket_logging({
      #  bucket: website_bucket_name,
      #  bucket_logging_status: {
      #    logging_enabled: {
      #      target_bucket: logging_bucket_name,
      #      target_prefix: '',
      #      target_grants: [
      #        {
      #          grantee: {
      #            type: 'Group',
      #            uri: 'http://acs.amazonaws.com/groups/s3/LogDelivery',
      #          },
      #          permission: 'READ_ACP',
      #        },
      #        {
      #          grantee: {
      #            type: 'Group',
      #            uri: 'http://acs.amazonaws.com/groups/s3/LogDelivery',
      #          },
      #          permission: 'WRITE',
      #        },
      #      ],
      #    },
      #  },
      #})
      client.put_bucket_website({
        bucket: website_bucket_name,
        website_configuration: {
          index_document: {
            suffix: 'index.html',
          },
        },
      })
    end
  end

  def valid_host_prefix?
    host_prefix? &&
      Deployment.where(host_prefix: host_prefix).none? &&
      !Aws::S3::Bucket.new(website_bucket_name).exists? &&
      !Aws::S3::Bucket.new(logging_bucket_name).exists?
  end
end

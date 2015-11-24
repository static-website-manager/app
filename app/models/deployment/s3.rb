class Deployment::S3 < Deployment
  store :settings, accessors: %i[aws_access_key_id aws_s3_bucket aws_secret_access_key aws_region]

  validates :aws_access_key_id, presence: true
  validates :aws_s3_bucket, presence: true
  validates :aws_secret_access_key, presence: true
  validates :aws_region, presence: true, inclusion: { in: %w[us-east-1 us-west-1 us-west-2] }

  def url
    "http://#{aws_s3_bucket}.s3-website-#{aws_region}.amazonaws.com/"
  end
end

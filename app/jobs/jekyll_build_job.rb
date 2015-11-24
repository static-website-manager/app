class JekyllBuildJob < ActiveJob::Base
  queue_as :default

  def perform(website, branch_name, commit_id)
    deployment = website.deployments.where(branch_name: branch_name, type: 'Deployment::S3').first

    uri = URI('http://build:9292/jekyll')

    if deployment
      data = {
        aws_access_key_id: deployment.aws_access_key_id,
        aws_s3_bucket: deployment.aws_s3_bucket,
        aws_secret_access_key: deployment.aws_secret_access_key,
        aws_region: deployment.aws_region,
        branch_name: branch_name,
        commit_id: commit_id,
        website_id: website.id,
      }
    else
      data = {
        branch_name: branch_name,
        commit_id: commit_id,
        website_id: website.id,
      }
    end

    response = Net::HTTP.post_form(uri, data)

    $stdout.puts response.body
  end
end

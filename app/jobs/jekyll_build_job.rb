class JekyllBuildJob < ActiveJob::Base
  queue_as :default

  def perform(deployment)
    uri = URI('http://build:9292/jekyll')

    data = {
      website_id: deployment.website_id,
      deployment_id: deployment.id,
      branch_name: deployment.branch_name,
      bucket_name: deployment.website_bucket_name,
    }

    response = Net::HTTP.post_form(uri, data)

    deployment.update(
      response_status: response.code,
      response_message: response.body,
    )
  end
end

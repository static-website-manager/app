class JekyllBuildJob < ActiveJob::Base
  queue_as :default

  def perform(website_id, branch_name, commit_id)
    uri = URI('http://build:9292/jekyll')

    data = {
      website_id: website_id,
      branch_name: branch_name,
      commit_id: commit_id,
    }

    response = Net::HTTP.post_form(uri, data)

    $stdout.puts response.body
  end
end

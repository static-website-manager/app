#!/usr/bin/ruby

require 'net/http'
require 'sequel'
require 'uri'

DB = Sequel.connect('postgres://postgres@postgres:5432/static_website_manager_development')

website_id = 'WEBSITE_ID'

if website_id.match(/\A\d{1,9}\z/)
  while (input = STDIN.read) != ''
    full_ref = input.split(' ').last
    branch_name = full_ref.sub(/\Arefs\/heads\//, '')
    deployment = DB[:deployments].where(website_id: website_id.to_i, branch_name: branch_name).first

    if deployment
      puts 'Scheduling Deployment...'
      uri = URI('http://build:9292/jekyll')

      data = {
        website_id: deployment[:website_id],
        deployment_id: deployment[:id],
        branch_name: deployment[:branch_name],
        bucket_name: "#{deployment[:host_prefix]}.staticwebsitemanager",
      }

      response = Net::HTTP.post_form(uri, data)

      DB[:deployments].where(website_id: website_id.to_i, branch_name: branch_name).update(
        response_status: response.code,
        response_message: response.body,
        updated_at: Time.now,
      )

      puts "Deployed #{response.code}: #{response.body}"
    end
  end
end

#!/usr/bin/ruby

require 'sequel'

DB = Sequel.connect('postgres://postgres@postgres:5432/static_website_manager_development')

website_id = 'WEBSITE_ID'

if website_id.match(/\A\d{1,9}\z/)
  while (input = STDIN.read) != ''
    ref = input.split(' ').last
    deployment = DB[:deployments].where(website_id: website_id.to_i, branch_name: ref).first

    if deployment
      puts 'Scheduling Deployment...'
    end
  end
end

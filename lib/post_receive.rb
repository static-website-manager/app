#!/usr/bin/ruby

require 'net/http'
require 'uri'

website_id = 'WEBSITE_ID'

while (input = STDIN.read) != ''
  full_ref = input.split(' ').last
  branch_name = full_ref.sub(/\Arefs\/heads\//, '')
  uri = URI('http://hooks:3000/git_post_receive')
  response = Net::HTTP.post_form(uri, token: 'GIT_HOOK_TOKEN', website_id: website_id, branch_name: branch_name)
  puts response.body
end

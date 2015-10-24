#!/usr/bin/ruby

require 'net/http'
require 'uri'

website_id = 'WEBSITE_ID'

while (input = STDIN.read) != ''
  full_ref = input.split(' ').last
  branch_name = full_ref.sub(/\Arefs\/heads\//, '')
  uri = URI('http://app:3000/post_receive_hook')
  response = Net::HTTP.post_form(uri, website_id: website_id, branch_name: branch_name)
  puts response.body
end

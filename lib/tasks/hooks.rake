namespace :hooks do
  namespace :post_receive do
    desc 'Update the post-receive hook for all existing repositories'
    task update: :environment do |task|
      Website.find_each(&:update_post_receive!)
    end
  end
end

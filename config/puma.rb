workers 1
threads 8,32
preload_app!
rackup DefaultRackup
environment ENV['RAILS_ENV'] || 'development'

on_worker_boot do
  ActiveRecord::Base.establish_connection
end

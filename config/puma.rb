workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads Integer(ENV['MIN_THREADS'] || 2), Integer(ENV['MAX_THREADS'] || 5)
preload_app!
rackup DefaultRackup
port 3000
environment ENV['RAILS_ENV'] || 'development'

on_worker_boot do
  ActiveRecord::Base.establish_connection
end

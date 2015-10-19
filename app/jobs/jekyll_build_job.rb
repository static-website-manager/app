class JekyllBuildJob < ActiveJob::Base
  queue_as :default

  def perform(deployment)
  end
end

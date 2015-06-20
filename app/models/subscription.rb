class Subscription
  include ActiveModel::Model

  attr_reader :user, :website

  def initialize(*args)
    super
    @user ||= User.new
    @website ||= Website.new
  end

  def save
    begin
      ActiveRecord::Base.transaction do
        @user.save!
        @website.save!
        @authorization = Authorization.create!(user: @user, website: @website)
      end

      true
    rescue ActiveRecord::RecordInvalid
      false
    end
  end

  def user_attributes=(attributes)
    @user = User.new(attributes)
  end

  def website_attributes=(attributes)
    @website = Website.new(attributes)
  end
end

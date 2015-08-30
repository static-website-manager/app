class Subscription
  include ActiveModel::Model

  attr_reader :user, :website

  def initialize
    @user = User.new
    @website = Website.new
  end

  def save(subscription_params)
    begin
      @user.assign_attributes(subscription_params[:user_attributes] || {})
      @website.assign_attributes(subscription_params[:website_attributes] || {})

      ActiveRecord::Base.transaction do
        @user.save
        @website.save

        if [@user, @website].any? { |model| model.new_record? || model.errors.any? }
          raise ActiveRecord::RecordInvalid, self
        else
          @authorization = Authorization.create!(user: @user, website: @website)
        end
      end

      true
    rescue ActiveRecord::RecordInvalid
      false
    end
  end
end

class Subscription
  include ActiveModel::Model

  attr_accessor :authorization, :user, :website

  def initialize(*args)
    @authorization = Authorization.new
    @user = User.new
    @website = Website.new
    super
  end

  def authorization_attributes=(*args)
    @authorization.assign_attributes(*args)
  end

  def user_attributes=(*args)
    @user.assign_attributes(*args)
  end

  def website_attributes=(*args)
    @website.assign_attributes(*args)
  end

  def save
    ActiveRecord::Base.transaction do
      @user.save
      @website.save
      @authorization.user = @user
      @authorization.website = @website
      @authorization.owner = true
      @authorization.ssh_access = true
      @authorization.save

      @authorization.errors.each do |attribute, error|
        errors.add attribute, error
      end

      @user.errors.each do |attribute, error|
        errors.add attribute, error
      end

      @website.errors.each do |attribute, error|
        errors.add attribute, error
      end

      if errors.any?
        raise ActiveRecord::Rollback
      else
        true
      end
    end
  end
end

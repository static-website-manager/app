class Subscription
  include ActiveModel::Model

  attr_accessor :authorization, :payment_information, :user, :website

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

      @user.errors.each do |attribute, error|
        errors.add attribute, error
      end

      if errors.any?
        raise ActiveRecord::Rollback
      end

      @website.subscription_status = :trialing

      unless @website.valid?
        @website.errors.each do |attribute, error|
          errors.add attribute, error
        end

        raise ActiveRecord::Rollback
      end

      if payment_information.blank?
        errors.add :payment_information, :blank
        raise ActiveRecord::Rollback
      end

      stripe_customer = nil
      new_stripe_customer = nil

      begin
        if @website.stripe_customer_token?
          stripe_customer = Stripe::Customer.retrieve(stripe_customer_token)
        end

        if stripe_customer
          stripe_customer.source = payment_information
          stripe_customer.save
        else
          stripe_customer = new_stripe_customer = Stripe::Customer.create(source: payment_information)
        end

        raise StandardError unless stripe_customer
      rescue Stripe::InvalidRequestError => e
        new_stripe_customer.try(:delete)
        errors.add :base, e.message
        raise ActiveRecord::Rollback
      rescue
        new_stripe_customer.try(:delete)
        errors.add :payment_information, :invalid
        raise ActiveRecord::Rollback
      end

      stripe_subscription = stripe_customer.subscriptions.create(
        plan: [@website.subscription_plan, @website.yearly_billing? ? 'yearly' : 'monthly'].join('_'),
      )

      @website.stripe_customer_token = stripe_customer.id
      @website.stripe_subscription_token = stripe_subscription.id
      @website.save(context: :payment_information)

      @website.errors.each do |attribute, error|
        errors.add attribute, error
      end

      if errors.any?
        stripe_subscription.delete
        new_stripe_customer.delete
        raise ActiveRecord::Rollback
      end

      @authorization.user = @user
      @authorization.website = @website
      @authorization.content_role = :designer
      @authorization.account_owner = true
      @authorization.ssh_access = true
      @authorization.production_branch_access = true
      @authorization.staging_branch_access = true
      @authorization.custom_branch_access = true
      @authorization.save

      @authorization.errors.each do |attribute, error|
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

class Subscription < Form
  models :user, :website, :authorization

  def setup_authorization(authorization)
    authorization.user = user
    authorization.website = website
  end
end

Rails.application.routes.draw do
  root to: 'marketings#root'

  get :subscribe, to: 'subscriptions#new'
end

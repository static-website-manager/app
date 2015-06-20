Rails.application.routes.draw do
  root to: 'marketings#root'

  get :subscribe, to: 'subscriptions#new'
  post :subscribe, to: 'subscriptions#create'

  resources :websites, only: %i[index show] do
    get :setup, to: 'setups#new'
    post :setup, to: 'setups#create'
  end
end

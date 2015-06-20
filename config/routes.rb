Rails.application.routes.draw do
  root to: 'marketings#root'

  get :subscribe, to: 'subscriptions#new'
  post :subscribe, to: 'subscriptions#create'

  get :sign_in, to: 'sessions#new'
  post :sign_in, to: 'sessions#create'
  delete :sign_out, to: 'sessions#destroy'

  resources :websites, only: %i[index show] do
    get :setup, to: 'setups#new'
    post :setup, to: 'setups#create'
  end
end

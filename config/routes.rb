Rails.application.routes.draw do
  root to: 'marketings#root'

  resource :session, only: %i[new create], path: 'sign-in', path_names: { new: '' }
  resource :session, only: %i[destroy], path: 'sign-out'
  resources :subscriptions, only: %i[new create], path: 'subscribe', path_names: { new: '' }

  resources :websites, only: %i[index show] do
    resource :setup, only: %i[new create], path_names: { new: '' }
    resources :branches, only: %i[show], path: '' do
      resources :collections, only: %i[index]
      resources :pages, only: %i[index]
      resources :posts, only: %i[index]
    end
  end
end

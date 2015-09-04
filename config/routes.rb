Rails.application.routes.draw do
  root to: 'marketings#root'

  resource :session, only: %i[new create], path: 'sign-in', path_names: { new: '' }
  resource :session, only: %i[destroy], path: 'sign-out', as: :sign_out
  resources :subscriptions, only: %i[new create], path: 'subscribe', path_names: { new: '' }

  resources :websites, only: %i[index show] do
    resource :settings, only: %i[edit update], path_names: { edit: '' }
    resource :setup, only: %i[new create], path_names: { new: '' }
    resource :setup_check, only: %i[show]
    resources :authorizations, only: %i[index new create edit update destroy], path: 'team'
    resources :checkouts, only: %i[new create], path: 'checkout', path_names: { new: '' }
    resources :branches, only: %i[show], path: '' do
      resources :branches, only: %i[show], controller: 'comparisons', path: 'compare'
      resources :commits, only: %i[index], controller: 'branch_commits', path: 'history'
      resources :drafts, only: %i[index edit update]
      resources :pages, only: %i[index edit update]
      resources :posts, only: %i[index edit update]
      resources :blobs, only: %i[] do
        resources :commits, only: %i[index], controller: 'blob_commits', path: 'history'
      end
    end
    resources :commits, only: %i[show]
  end
end

Rails.application.routes.draw do
  root to: 'marketings#root'

  resource :account, only: %i[edit update], path_names: { edit: '' }
  resource :email_confirmation, only: %i[new create show], path: 'confirm-email', path_names: { new: 'resend' }
  resource :password_reset, only: %i[edit update], path: 'reset-password', path_names: { edit: '' }
  resource :password_forget, only: %i[new create], path: 'forget-password', path_names: { new: '' }
  resource :session, only: %i[new create], path: 'sign-in', path_names: { new: '' }
  resource :session, only: %i[destroy], path: 'sign-out', as: :sign_out
  resources :subscriptions, only: %i[new create], path: 'subscribe', path_names: { new: '' }

  resources :websites, only: %i[index show] do
    resource :settings, only: %i[edit update], path_names: { edit: '' }
    resource :setup, only: %i[new show], path_names: { new: '' }
    resources :authorizations, only: %i[index new create edit update destroy], path: 'team'
    resources :branches, only: %i[show], path: '' do
      resources :branches, only: %i[show], controller: 'comparisons', path: 'compare' do
        post :merge, on: :member
      end
      resources :checkouts, only: %i[new create], path: 'checkout', path_names: { new: '' }
      resources :commits, only: %i[index], controller: 'branch_commits', path: 'history'
      resources :drafts, only: %i[index new create show edit update] do
        resources :commits, only: %i[index], controller: 'draft_commits', path: 'history'
      end
      resources :pages, only: %i[index new create show edit update] do
        resources :commits, only: %i[index], controller: 'page_commits', path: 'history'
      end
      resources :posts, only: %i[index new create show edit update] do
        resources :commits, only: %i[index], controller: 'post_commits', path: 'history'
      end
    end
    resources :commits, only: %i[show]
  end
end

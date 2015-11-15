Rails.application.routes.draw do
  resource :account, only: %i[edit update], path_names: { edit: '' } do
    resource :email, only: %i[edit update], path_names: { edit: '' }
    resource :password, only: %i[edit update], path_names: { edit: '' }
    resource :ssh_keys, only: %i[edit update], path: 'ssh-keys', path_names: { edit: '' }
  end
  resource :email_confirmation, only: %i[new create show], path: 'confirm-email', path_names: { new: 'resend' }
  resource :git_post_receive, only: %i[create]
  resource :password_reset, only: %i[edit update], path: 'reset-password', path_names: { edit: '' }
  resource :password_forget, only: %i[new create], path: 'forget-password', path_names: { new: '' }
  resource :password, only: %i[new create], path: 'password', path_names: { new: 'set' }
  resource :session, only: %i[new create], path: 'sign-in', path_names: { new: '' }
  resource :session, only: %i[destroy], path: 'sign-out', as: :sign_out
  resources :subscriptions, only: %i[new create], path: 'subscribe', path_names: { new: '' }

  resources :websites, only: %i[index new create show], path_names: { new: 'subscribe' } do
    resource :settings, only: %i[edit update], path_names: { edit: '' }
    resource :setup, only: %i[show] do
      resource :check, only: %i[show], controller: 'setup_checks'
      resource :authentication, only: %i[create], controller: 'setup_authentications', path: 'ssh'
      resources :authorizations, only: %i[new create], controller: 'setup_authorizations', path: 'team', path_names: { new: '' }
    end
    resource :subscription_settings, only: %i[edit update], path: 'subscription', path_names: { edit: '' }
    resources :authorizations, only: %i[index new create edit update destroy], path: 'team'
    resources :branches, only: %i[show destroy], path: '' do
      get :delete, on: :member
      resource :checkout, only: %i[new create], path_names: { new: '' }
      resource :config, only: %i[edit update], path_names: { edit: '' }
      resource :deployment, only: %i[new create update destroy] do
        get :delete
      end
      resource :design, only: %i[show]
      resource :merge, only: %i[new create], path_names: { new: '' }
      resource :move, only: %i[new create], controller: 'branch_moves', path: 'rename', path_names: { new: '' }
      resource :rebase, only: %i[new create], path_names: { new: '' }
      resources :collections, only: %i[index]
      resources :commits, only: %i[index], controller: 'branch_commits', path: 'history'
      resources :datasets, only: %i[index show], id: /.+/, path: 'data'
      resources :drafts, id: /.+/ do
        get :delete, on: :member
        resources :commits, only: %i[index], controller: 'draft_commits', path: 'history'
        resource :move, only: %i[new create], controller: 'draft_moves', path: 'rename', path_names: { new: '' }
        resource :publication, only: %i[new create], controller: 'draft_publications', path: 'publish', path_names: { new: '' }
      end
      resources :static_files, id: /.+/, path: 'files' do
        get :delete, on: :member
        resources :commits, only: %i[index], controller: 'static_file_commits', path: 'history'
        resource :move, only: %i[new create], controller: 'static_file_moves', path: 'rename'
      end
      resources :pages, id: /.+/ do
        get :delete, on: :member
        resources :commits, only: %i[index], controller: 'page_commits', path: 'history'
        resource :move, only: %i[new create], controller: 'page_moves', path: 'rename'
      end
      resources :posts, id: /.+/ do
        get :delete, on: :member
        resources :commits, only: %i[index], controller: 'post_commits', path: 'history'
        resource :move, only: %i[new create], controller: 'post_moves', path: 'rename'
      end
    end
    resources :commits, only: %i[show]
  end
end

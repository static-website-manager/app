Rails.application.routes.draw do
  constraints host: 'hooks' do
    resource :git_post_receive, only: %i[create]
  end

  resource :account, only: %i[edit update], path_names: { edit: '' } do
    resource :email, only: %i[edit update destroy], path_names: { edit: '' }
    resource :password, only: %i[edit update], path_names: { edit: '' }
    resource :ssh_keys, only: %i[edit update], path: 'ssh-keys', path_names: { edit: '' }
  end
  resource :email_confirmation, only: %i[new create show], path: 'confirm-email', path_names: { new: 'resend' }
  resource :password_reset, only: %i[edit update], path: 'reset-password', path_names: { edit: '' }
  resource :password_forget, only: %i[new create], path: 'forget-password', path_names: { new: '' }
  resource :password, only: %i[new create], path: 'password', path_names: { new: 'set' }
  resource :session, only: %i[new create], path: 'sign-in', path_names: { new: '' }
  resource :session, only: %i[destroy], path: 'sign-out', as: :sign_out
  resource :waiting_list, only: %i[new], path: 'waiting-list', path_names: { new: 'join' }
  resources :form_responders, only: [], path: 'form-responders' do
    resources :submissions, only: %i[create update], controller: 'form_responder_submissions', path: '', id: /.+/
  end
  resources :subscriptions, only: %i[new create], path: 'subscribe', path_names: { new: '' }

  resources :websites, only: %i[index new create show destroy], path_names: { new: 'subscribe' } do
    get :delete, on: :member
    resource :branch_settings, only: %i[edit update], path: 'settings/branches', path_names: { edit: '' }
    resource :settings, only: %i[edit update], path_names: { edit: '' }
    resource :setup, only: %i[show] do
      resource :check, only: %i[show], controller: 'setup_checks'
      resource :authentication, only: %i[create], controller: 'setup_authentications', path: 'ssh'
      resources :authorizations, only: %i[new create], controller: 'setup_authorizations', path: 'team', path_names: { new: '' }
    end
    resource :subscription_settings, only: %i[edit update], path: 'subscription', path_names: { edit: '' }
    resources :authorizations, only: %i[index new create edit update destroy], path: 'team', path_names: { new: 'new' }
    resources :branches, only: %i[show destroy], path: '' do
      get :delete, on: :member
      resource :checkout, only: %i[new create], path_names: { new: '' }
      resource :config, only: %i[edit update], path_names: { edit: '' }
      resource :design, only: %i[show]
      resource :merge, only: %i[new create destroy], path_names: { new: '' } do
        get :delete, on: :member, path: 'scrap'
      end
      resource :move, only: %i[new create], controller: 'branch_moves', path: 'rename', path_names: { new: '' }
      resource :rebase, only: %i[new create], path_names: { new: '' }
      resources :collections, only: %i[index]
      resources :commits, only: %i[index show destroy], controller: 'branch_commits', path: 'history' do
	get :delete, on: :member
	resource :restore, only: %i[new create]
      end
      resources :datasets, only: %i[index show], id: /.+/, path: 'data'
      resources :drafts, id: /.+/, path_names: { new: 'new' } do
        get :delete, on: :member
        resources :commits, only: %i[index], controller: 'draft_commits', path: 'history'
        resource :move, only: %i[new create], controller: 'draft_moves', path: 'rename', path_names: { new: '' }
        resource :publication, only: %i[new create], controller: 'draft_publications', path: 'publish', path_names: { new: '' }
      end
      resources :form_responders, only: %i[new create edit update destroy], path: 'form-responders', path_names: { new: 'new' } do
        get :delete, on: :member
        resource :activation, only: %i[create destroy], controller: 'form_responder_activations'
      end
      resources :static_files, id: /.+/, path: 'files', path_names: { new: 'new' } do
        get :delete, on: :member
        resources :commits, only: %i[index], controller: 'static_file_commits', path: 'history'
        resource :move, only: %i[new create], controller: 'static_file_moves', path: 'rename', path_names: { new: '' }
      end
      resources :pages, id: /.+/, path_names: { new: 'new' } do
        get :delete, on: :member
        resources :commits, only: %i[index], controller: 'page_commits', path: 'history'
        resource :move, only: %i[new create], controller: 'page_moves', path: 'rename', path_names: { new: '' }
      end
      resources :posts, id: /.+/, path_names: { new: 'new' } do
        get :delete, on: :member
        resources :commits, only: %i[index], controller: 'post_commits', path: 'history'
        resource :move, only: %i[new create], controller: 'post_moves', path: 'rename', path_names: { new: '' }
      end
      resources :deployment_s3s, only: %i[new create show edit update destroy], path: 'deployments/s3' do
        get :delete, on: :member
      end
    end
  end
end

Rails.application.routes.draw do
  root to: 'marketings#root'

  resource :account, only: %i[edit update], path_names: { edit: '' }
  resource :email_confirmation, only: %i[new create show], path: 'confirm-email', path_names: { new: 'resend' }
  resource :password_reset, only: %i[edit update], path: 'reset-password', path_names: { edit: '' }
  resource :password_forget, only: %i[new create], path: 'forget-password', path_names: { new: '' }
  resource :post_receive_hook, only: %i[create]
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
    resources :authorizations, only: %i[index new create edit update destroy], path: 'team'
    resources :branches, only: %i[show destroy], path: '' do
      get :delete, on: :member
      resource :checkout, only: %i[new create], path_names: { new: '' }
      resource :deployment, only: %i[new create destroy] do
        get :delete
      end
      resource :design, only: %i[show]
      resource :merge, only: %i[new create], path_names: { new: '' }
      resource :move, only: %i[new create], controller: 'branch_moves', path: 'rename', path_names: { new: '' }
      resource :rebase, only: %i[new create], path_names: { new: '' }
      resources :collections, only: %i[index]
      resources :commits, only: %i[index], controller: 'branch_commits', path: 'history'
    end
    resources :commits, only: %i[show]
  end

  get 'websites/:website_id/:branch_id/pages/new', to: 'pages#new', as: :new_website_branch_page, format: false
  post 'websites/:website_id/:branch_id/pages', to: 'pages#create', format: false
  get 'websites/:website_id/:branch_id/pages/*page_id/rename', to: 'page_moves#new', as: :new_website_branch_page_move, format: false
  post 'websites/:website_id/:branch_id/pages/*page_id/rename', to: 'page_moves#create', as: :website_branch_page_move, format: false
  get 'websites/:website_id/:branch_id/pages/*page_id/history', to: 'page_commits#index', as: :website_branch_page_commits, format: false
  get 'websites/:website_id/:branch_id/pages/*id/delete', to: 'pages#delete', as: :delete_website_branch_page, format: false
  delete 'websites/:website_id/:branch_id/pages/*id', to: 'pages#destroy', format: false
  get 'websites/:website_id/:branch_id/pages/*id/edit', to: 'pages#edit', as: :edit_website_branch_page, format: false
  put 'websites/:website_id/:branch_id/pages/*id', to: 'pages#update', format: false
  patch 'websites/:website_id/:branch_id/pages/*id', to: 'pages#update', format: false
  get 'websites/:website_id/:branch_id/pages/*id', to: 'pages#show', as: :website_branch_page, format: false
  get 'websites/:website_id/:branch_id/pages', to: 'pages#index', as: :website_branch_pages, format: false

  get 'websites/:website_id/:branch_id/drafts/new', to: 'drafts#new', as: :new_website_branch_draft, format: false
  post 'websites/:website_id/:branch_id/drafts', to: 'drafts#create', format: false
  get 'websites/:website_id/:branch_id/drafts/*draft_id/publish', to: 'draft_publications#new', as: :new_website_branch_draft_publication, format: false
  post 'websites/:website_id/:branch_id/drafts/*draft_id/publish', to: 'draft_publications#create', as: :website_branch_draft_publication, format: false
  get 'websites/:website_id/:branch_id/drafts/*draft_id/rename', to: 'draft_moves#new', as: :new_website_branch_draft_move, format: false
  post 'websites/:website_id/:branch_id/drafts/*draft_id/rename', to: 'draft_moves#create', as: :website_branch_draft_move, format: false
  get 'websites/:website_id/:branch_id/drafts/*draft_id/history', to: 'draft_commits#index', as: :website_branch_draft_commits, format: false
  get 'websites/:website_id/:branch_id/drafts/*id/delete', to: 'drafts#delete', as: :delete_website_branch_draft, format: false
  delete 'websites/:website_id/:branch_id/drafts/*id', to: 'drafts#destroy', format: false
  get 'websites/:website_id/:branch_id/drafts/*id/edit', to: 'drafts#edit', as: :edit_website_branch_draft, format: false
  put 'websites/:website_id/:branch_id/drafts/*id', to: 'drafts#update', format: false
  patch 'websites/:website_id/:branch_id/drafts/*id', to: 'drafts#update', format: false
  get 'websites/:website_id/:branch_id/drafts/*id', to: 'drafts#show', as: :website_branch_draft, format: false
  get 'websites/:website_id/:branch_id/drafts', to: 'drafts#index', as: :website_branch_drafts, format: false

  get 'websites/:website_id/:branch_id/posts/new', to: 'posts#new', as: :new_website_branch_post, format: false
  post 'websites/:website_id/:branch_id/posts', to: 'posts#create', format: false
  get 'websites/:website_id/:branch_id/posts/*post_id/rename', to: 'post_moves#new', as: :new_website_branch_post_move, format: false
  post 'websites/:website_id/:branch_id/posts/*post_id/rename', to: 'post_moves#create', as: :website_branch_post_move, format: false
  get 'websites/:website_id/:branch_id/posts/*post_id/history', to: 'post_commits#index', as: :website_branch_post_commits, format: false
  get 'websites/:website_id/:branch_id/posts/*id/delete', to: 'posts#delete', as: :delete_website_branch_post, format: false
  delete 'websites/:website_id/:branch_id/posts/*id', to: 'posts#destroy', format: false
  get 'websites/:website_id/:branch_id/posts/*id/edit', to: 'posts#edit', as: :edit_website_branch_post, format: false
  put 'websites/:website_id/:branch_id/posts/*id', to: 'posts#update', format: false
  patch 'websites/:website_id/:branch_id/posts/*id', to: 'posts#update', format: false
  get 'websites/:website_id/:branch_id/posts/*id', to: 'posts#show', as: :website_branch_post, format: false
  get 'websites/:website_id/:branch_id/posts', to: 'posts#index', as: :website_branch_posts, format: false

  get 'websites/:website_id/:branch_id/files/*static_file_id/rename', to: 'static_file_moves#new', as: :new_website_branch_static_file_move, format: false
  post 'websites/:website_id/:branch_id/files/*static_file_id/rename', to: 'static_file_moves#create', as: :website_branch_static_file_move, format: false
  get 'websites/:website_id/:branch_id/files/*static_file_id/download', to: 'static_file_downloads#show', as: :download_website_branch_static_file, format: false
  get 'websites/:website_id/:branch_id/files/*static_file_id/preview', to: 'static_file_previews#show', as: :preview_website_branch_static_file, format: false
  get 'websites/:website_id/:branch_id/files/*static_file_id/history', to: 'static_file_commits#index', as: :website_branch_static_file_commits, format: false
  get 'websites/:website_id/:branch_id/files/*id/delete', to: 'static_files#delete', as: :delete_website_branch_static_file, format: false
  delete 'websites/:website_id/:branch_id/files/*id', to: 'static_files#destroy', format: false
  get 'websites/:website_id/:branch_id/files/*id', to: 'static_files#show', as: :website_branch_static_file, format: false
  get 'websites/:website_id/:branch_id/files', to: 'static_files#index', as: :website_branch_static_files, format: false
end

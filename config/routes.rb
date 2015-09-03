Rails.application.routes.draw do
  resources :users, only: [:new, :create]
  resource :account, only: :destroy
  resource :session, only: [:new, :create, :destroy]

  get 'signup' => 'users#new'
  get 'login' => 'sessions#new'
  get 'logout' => 'sessions#destroy'

  scope path: '/:user_id' do
    resources :playlists, only: :create
    root to: 'playlists#new', as: :new_playlist
    get 'playlist' => 'playlists#list'
  end

  resources :playlists, only: [] do
    member { patch :ack }
  end

  root 'playlists#index'
end

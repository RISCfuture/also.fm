Rails.application.routes.draw do
  resources :users, only: [:new, :create] do
    resources :playlists, controller: 'user/playlists', only: [:index, :create]
  end
  resource :account, only: :destroy do
    resources :playlists, controller: 'account/playlists', only: :index do
      member { patch :ack }
    end
  end
  resource :session, only: [:new, :create, :destroy]

  get 'signup' => 'users#new'
  get 'login' => 'sessions#new'
  get 'logout' => 'sessions#destroy'

  scope path: '/:user_id' do
    get '' => 'user/playlists#new', as: :new_playlist
    get 'playlist' => 'user/playlists#index'
    get 'playlist/name' => 'playlists#name', as: :guess_name
  end

  root 'playlists#index'
end

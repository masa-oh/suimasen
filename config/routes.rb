Rails.application.routes.draw do
  root to: 'home#index'
  namespace :api do
    resources :games do
      resources :stages
    end
    post 'games/:id/transcribe', to: 'games#transcribe'
  end
  get '*path', to: 'home#index'
end

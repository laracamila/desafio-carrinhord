require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :products
  get "up" => "rails/health#show", as: :rails_health_check

  # Rotas do carrinho
  get    '/cart',             to: 'carts#show'
  post   '/cart',             to: 'carts#create'
  post   '/cart/add_item',    to: 'carts#add_item'
  post   '/cart/add_items',   to: 'carts#add_item'
  delete '/cart/:product_id', to: 'carts#destroy'

  root "rails/health#show"
end

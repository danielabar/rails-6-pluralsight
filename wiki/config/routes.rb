# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  resources :wiki_posts
  get 'welcome/index'
  root 'welcome#index'
end

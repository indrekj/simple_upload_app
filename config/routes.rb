SimpleUploadApp::Application.routes.draw do
  resources :assets
  resources :links
  resources :messages

  match "assets/category/:name" => "assets#category", :as => :category

  root :to => "assets#index"
end

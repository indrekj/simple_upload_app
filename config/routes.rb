SimpleUploadApp::Application.routes.draw do
  resources :assets
  resources :assessments
  resources :links
  resources :messages

  match "assessments/category/:name" => "assessments#category", :as => :category

  root :to => "assessments#index"
end

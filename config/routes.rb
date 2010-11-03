SimpleUploadApp::Application.routes.draw do
  resources :assessments do
    collection do
      get :exists
    end
  end

  resources :links

  match "assessments/category/:name" => "assessments#category", :as => :category

  root :to => "assessments#index"
end

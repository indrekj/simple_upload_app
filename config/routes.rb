SimpleUploadApp::Application.routes.draw do
  resources :categories, :only => [] do
    resources :assessments, :only => [:index]
  end

  resources :assessments do
    collection do
      get :exists
    end
  end

  resources :links

  root :to => "assessments#index"
end

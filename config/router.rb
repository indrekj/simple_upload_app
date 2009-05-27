Merb.logger.info("Compiling routes...")
Merb::Router.prepare do
  resources :assets
  resources :links
  resources :messages

  match('/').to(:controller => 'assets', :action => 'index')
end

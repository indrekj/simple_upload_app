Merb.logger.info("Compiling routes...")
Merb::Router.prepare do
  resources :assets
  resources :links

  match('/').to(:controller => 'assets', :action => 'index')
end

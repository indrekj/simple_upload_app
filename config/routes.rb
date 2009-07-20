ActionController::Routing::Routes.draw do |map|
  map.resources :assets, :links, :messages

  map.home '/', :controller => 'assets', :action => 'index'
end

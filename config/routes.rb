ActionController::Routing::Routes.draw do |map|
  map.resources :calendars

  map.resources :assets, :links, :messages
  map.category 'assets/category/:name', :controller => 'assets', :action => 'category'

  map.home '/', :controller => 'assets', :action => 'index'
end

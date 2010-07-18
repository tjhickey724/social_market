ActionController::Routing::Routes.draw do |map|
  map.resources :positions

  map.resources :portfolios

  map.resources :purchases

  map.root :controller => 'stocks', :action => 'welcome'
  map.login "login", :controller => "user_sessions", :action => "new"
  map.logout "logout", :controller => "user_sessions", :action => "destroy"
 
  map.connect 'stocks/welcome', :controller => 'stocks', :action => 'welcome'
  map.connect 'portfolio/list.:format', :controller => 'portfolios', :action => 'list'
  map.connect 'portfolio/list/:member.:format', :controller => 'portfolios', :action => 'list'

  map.connect 'portfolio/buy/:exchange/:symbol/:qty', :controller => 'portfolios', :action => 'buy'
  map.connect 'portfolio/sell/:exchange/:symbol/:qty', :controller => 'portfolios', :action => 'sell'
  map.connect 'portfolio/add', :controller => 'portfolios', :action => 'add'
  map.connect 'portfolio/remove/:symbol', :controller => 'portfolios', :action => 'remove'
  map.connect 'portfolio/rank.:format', :controller => 'portfolios', :action => 'rank'
  map.connect 'portfolio/leaders.:format', :controller => 'portfolios', :action => 'leaders'
  map.connect 'portfolio/local_leaders.:format', :controller => 'portfolios', :action => 'local_leaders'
  
  map.connect 'set_location/:lat/:lon', :controller => 'users', :action => 'set_location'
  map.connect 'get_locations/:lat/:lon/all.:format', :controller => 'users', :action => 'get_locations'
 
  map.resources :user_sessions

  map.resources :users

  map.resources :stocks

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action


  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end

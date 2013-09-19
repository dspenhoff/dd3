Dd3::Application.routes.draw do

  get "sessions/index"

  get "sessions/new"

  # routes for the dealduck site controller (static/non-application pages)
  resources :site do
    collection do
      get 'index'
      get 'info'
      get 'signin'
      get 'privacy'
      get 'blog'
      get 'faq'
      get 'about'
    end
  end
  
  #routes for deals
  resources :deals do
   collection do
    post 'order_deals'
    get 'index_deals'
    get 'scenario'
    post 'create_new_scenario'
    get 'index_first_page'
    get 'index_last_page'
    get 'index_previous_page'
    get 'index_next_page'
    get 'delete_random_deals'
   end
  end  

  # routes for reps
  resources :reps do
    resources :deals
    get 'order_reps', :on => :collection
    get 'rank_reps', :on => :collection
  end
  
  #routes for regions
  resources :regions do
    resources :reps
    get 'order_regions', :on => :collection
  end
  
  # routes for histories
  resources :histories do
    resources :reps
  end
  
  # routes for application home page
  resources :home
  
  # routes for analytics
  resources :analytics do
    collection do
      get 'summarize_deals'
      get 'summarize_all_reps'
      get 'summarize_all_regions'
      get 'summarize_this_rep'
      get 'summarize_this_region'
      get 'simulate_parameters'
      get 'chart_pdf_cdf'
      get 'chart_likely_histo'
      get 'chart_prob_histo'
      get 'chart_achieved_vs_x'
      get 'chart_achieved_vs_forecast'
      get 'chart_achieved_vs_pipeline'
    end
  end
    
  # routes for customers
  resources :customers
  
  # routes for scenarios
  resources :scenarios
  
  # resources for users
  resources :users
  
  # resources for sessions
  resources :sessions do
    collection do
      get 'signin_success'
      get 'signout_success'
    end
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'
  root :to => 'site#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id))(.:format)'
end

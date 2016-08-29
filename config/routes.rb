require 'resque/server'

Rails.application.routes.draw do
  resources :oai_recs

  resources :providers do
    member do
      post :harvest
      post :harvest_all_selective_contributing_institution
      post :harvest_all_selective_intermediate_provider
      post :dump_and_reindex_by_institution
      post :dump_and_reindex_by_set
    end
  end


  root :to => "catalog#index"

  get 'csv' => "csv#index"

  post "harvest_all_providers"=>"application#harvest_all_providers"
  post "dump_whole_index"=>"application#dump_whole_index"

  get 'about' => 'high_voltage/pages#show', id: 'about'
  get 'sponsors' => 'high_voltage/pages#show', id: 'sponsors'

  blacklight_for :catalog
  devise_for :users, :skip => [:registrations] 
  as :user do
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
  end

  authenticate :user do
    mount Resque::Server.new, at: "/resque"
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

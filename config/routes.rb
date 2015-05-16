Rails.application.routes.draw do
  post '/rate' => 'rater#create', :as => 'rate'
  devise_for :users, :controllers => {omniauth_callbacks: 'users/omniauth_callbacks', registrations: 'registrations' }

  scope '(:locale)' do
    root 'home#index'

    get 'dashboard',  to: 'dashboard#index'
    get 'about',      to: 'home#about'
    get 'delivery',   to: 'home#delivery'
    get 'news',       to: 'home#news'
    get 'map',        to: 'home#site_map'
    get 'services',   to: 'home#services'
    get 'contacts',   to: 'home#contacts'
    get  'feedback',  to: 'feedback#index'
    post 'feedback',  to: 'feedback#create'

    resource :shopping_cart do
      collection do
        put     :item, to: 'shopping_carts#item_quantity_update'
        delete  :item, to: 'shopping_carts#item_destroy'
      end
    end

    resources :categories

    resources :products do
      collection do
        get  :autocomplete
        get  :search
      end
      resources :comments
    end

    resources :orders do
      collection do
        post :paypal_notifications, to: 'orders#paypal_notifications'
        get  :paypal, to: 'orders#paypal_return'
        get  :choose_payment, to: 'orders#choose_payment_index'
        post :choose_payment
      end
    end


  namespace :admin do
    root 'dashboard#index'
    resources :users, :feedbacks, :vendors, :import_tasks, :news, :orders

    resources :products do
      collection do
        get     :featured,  to: 'products#featured_index'
        delete  :featured,  to: 'products#featured_destroy'
        get     :import,    to: 'products#import_index'
        post    :import
      end

      resources :images

    end

    resources :categories do
      collection do
        get  :nested_options
        post :rebuild, :expand_node
      end
    end
  end

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

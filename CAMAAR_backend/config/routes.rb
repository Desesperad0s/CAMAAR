Rails.application.routes.draw do
  get 'health_check', to: 'application#health_check'
  
  post 'auth/login', to: 'authentication#login'
  delete 'auth/logout', to: 'authentication#logout'
  get 'auth/me', to: 'authentication#me'
  post 'register', to: 'users#register'
  
  post 'import-data', to: 'data_import#import'
  
  post 'passwords/forgot', to: 'passwords#forgot'
  post 'passwords/reset', to: 'passwords#reset'
  post 'passwords/set-first', to: 'passwords#set_first_password'
  get 'passwords/test-email', to: 'passwords#test_email' # Apenas para desenvolvimento

  get 'turmas/code/:code', to: 'turmas#find_by_code'
  
  resources :alternativas
  resources :departamentos
  resources :disciplinas
  resources :questaos

  resources :formularios do
    collection do
      post :create_with_questions
      get 'report/excel', to: 'formularios#excel_report'
    end
    member do
      get :questoes
    end
  end
  
  resources :resposta do
    collection do
      post :batch_create
      get 'formulario/:formulario_id', to: 'resposta#by_formulario'
    end
  end
  
  resources :turmas do
    member do
      get :formularios
    end
  end
  
  get 'user/turmas', to: 'users#turmas'
  resources :users
  resources :admins
  resources :templates

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end

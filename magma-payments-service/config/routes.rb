MagmaPaymentsService::Application.routes.draw do
  namespace :v1 do
    resources :customers, only: [:create, :update] do
      resources :transactions, only: [:create, :index, :show]
    end
  end
  namespace :v2 do
    resources :customers, only: [:create, :update] do
      resources :transactions, only: [:create, :index, :show]
    end
  end
end

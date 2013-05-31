MagmaPaymentsService::Application.routes.draw do
  resources :customers, only: [:create, :update] do
    resources :transactions, only: [:create, :index, :show]
  end
end

MagmaPaymentsService::Application.routes.draw do
  api :version => 1 do
    resources :customers, only: [:create, :update] do
      resources :transactions, only: [:create, :index, :show]
    end
  end
end

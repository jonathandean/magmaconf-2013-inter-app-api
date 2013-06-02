MagmaPaymentsService::Application.routes.draw do
  (1..2).each do |version|
    namespace :"v#{version}" do
      resources :customers, only: [:create, :update] do
        resources :transactions, only: [:create, :index, :show]
      end
    end
  end
end

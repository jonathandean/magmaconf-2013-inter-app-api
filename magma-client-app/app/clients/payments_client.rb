class PaymentsClient < RocketPants::Client
  version '1'
  base_uri MagmaClientApp::Application.config.payments_base_uri

  class Result < APISmith::Smash
    property :success
    property :message
  end

  def create_customer(user)
    post 'customers', payload: { name: user.name, email: user.email }, transformer: Result
  end
end
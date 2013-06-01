class PaymentsService
  include HTTParty
  base_uri MagmaClientApp::Application.config.payments_base_uri
end

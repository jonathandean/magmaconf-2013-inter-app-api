class PaymentsService
  include HTTParty
  base_uri MagmaClientApp::Application.config.payments_base_uri

  def self.create_customer(user)
    params = {
        id:         user.id,
        first_name: user.name.split(' ').first,
        last_name:  user.name.split(' ').last,
        email:      user.email
    }
    options = { body: params, headers: { "Authorization" => authorization_credentials }}
    response = self.post('/customers.json', options)
    response.parsed_response
  end

  private

  def self.authorization_credentials
    token = MagmaClientApp::Application.config.payments_api_secret
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

end

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
    response = self.post('/customers.json', { body: params })
    response.parsed_response
  end

end

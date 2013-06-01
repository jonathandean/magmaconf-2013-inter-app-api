class User < ActiveRecord::Base

  attr_accessible :name, :email
  after_create :create_payments_customer

  def create_payments_customer
    params = {
        id:         self.id,
        first_name: self.name.split(' ').first,
        last_name:  self.name.split(' ').last,
        email:      self.email
    }
    response = HTTParty.post('http://localhost:3000/customers.json', { body: params })
    answer = response.parsed_response
    puts "response success: #{answer['success']}"
    puts "response message: #{answer['message']}"
  end

end

class User < ActiveRecord::Base

  attr_accessible :name, :email
  after_create :create_payments_customer

  def create_payments_customer
    answer = PaymentsClient.new.create_customer(self)
    puts "response success: #{answer.success}"
    puts "response message: #{answer.message}"
  end

end

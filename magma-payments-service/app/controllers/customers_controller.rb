class CustomersController < RocketPants::Base
  def create
    result = Braintree::Customer.create({
      :id => params[:id ],
      :first_name => params[:last_name],
      :last_name => params[:last_name],
      :email => params[:email]
    })
    expose({ success: result.success?, message: (result.message rescue '') })
  end
end
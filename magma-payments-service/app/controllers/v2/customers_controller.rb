module V2
  class CustomersController < ApplicationController
    def create
      # Need to send a hash of :id, :name, :email
      result = Braintree::Customer.create({
        :id => params[:id],
        :first_name => params[:name].split(' ').first,
        :last_name => params[:name].split(' ').last,
        :email => params[:email]
      })
      # Build a hash we can send as JSON in the response
      resp = { success: result.success?, message: (result.message rescue '') }
      # Render JSON as the response
      respond_to do |format|
        format.json { render json: resp }
      end
    end
  end
end

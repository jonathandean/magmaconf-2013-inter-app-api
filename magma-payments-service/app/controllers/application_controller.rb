class ApplicationController < ActionController::Base

  before_filter :authenticate

  private

  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      token == MagmaPaymentsService::Application.config.api_secret
    end
  end

end

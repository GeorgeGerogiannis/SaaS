class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler

  # called before every action on controllers
  before_action :authorize_request
  attr_reader :current_user

  rescue_from ExceptionHandler::InvalidToken, with: :unauthorized_request
  rescue_from ExceptionHandler::MissingToken, with: :unauthorized_request

  private

  # Check for valid request token and return user
  def authorize_request
    @current_user = (AuthorizeApiRequest.new(request.headers).call)[:user]
  end

  def unauthorized_request(e)
    render json: { message: e.message }, status: :unauthorized
  end

  before_action :cors_preflight_check

  def cors_preflight_check
    if request.method == "OPTIONS"
      headers['Access-Control-Allow-Origin'] = "*"
      headers['Access-Control-Allow-Methods'] = "POST, GET, PUT, DELETE, OPTIONS"
      headers['Access-Control-Allow-Headers'] = "Authorization, Content-Type"
      headers['Access-Control-Max-Age'] = "1728000"
      render text: "", content_type: "text/plain"
    end
  end
end

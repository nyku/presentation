class Api::BaseController < ApplicationController
  rescue_from ArgumentError, with: :handle_api_error
  skip_before_action :verify_authenticity_token

  private

  def api_user
    @api_user = User.find_by(
      app_id: request.headers["HTTP_APP_ID"],
      secret: request.headers["HTTP_SECRET"]
    )
    raise ArgumentError.new("User was not found") unless @api_user
    @api_user
  end

  def api_connection
    identifier = params[:id] || params[:connection_id]
    @api_connection = api_user.connections.find_by(id: identifier)
    raise ArgumentError.new("Connection with id: '#{identifier}'was not found") unless @api_connection
    @api_connection
  end

  def api_account
    @api_account = api_connection.accounts.find_by(id: params[:account_id])
    raise ArgumentError.new("Account with id: '#{params[:account_id]}' was not found") unless @api_account
    @api_account
  end


  def handle_api_error(error)
    render json: { error: error.message }, status: :invalid
  end
end

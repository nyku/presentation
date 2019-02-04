class Api::BaseController < ApplicationController
  rescue_from ArgumentError, with: :handle_api_error
  skip_before_action :verify_authenticity_token

  private

  def api_user
    app_id, secret = request.headers["HTTP_APP_ID"], request.headers["HTTP_SECRET"]

    Rails.cache.fetch("api_user:#{app_id}:#{secret}", expires_in: 24.hours) do
      @api_user = User.find_by(app_id: app_id, secret: secret)
      raise ArgumentError.new("User was not found") unless @api_user
      @api_user
    end
  end

  def api_connection
    identifier = params[:id] || params[:connection_id]

    Rails.cache.fetch("api_connection:#{identifier}", expires_in: 24.hours) do
      @api_connection = api_user.connections.find_by(id: identifier)
      raise ArgumentError.new("Connection with id: '#{identifier}'was not found") unless @api_connection
      @api_connection
    end
  end

  def api_account
    Rails.cache.fetch("api_account:#{params[:account_id]}", expires_in: 24.hours) do
      @api_account = api_connection.accounts.find_by(id: params[:account_id])
      raise ArgumentError.new("Account with id: '#{params[:account_id]}' was not found") unless @api_account
      @api_account
    end
  end


  def handle_api_error(error)
    render json: { error: error.message }, status: :invalid
  end
end

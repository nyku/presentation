class Api::AccountsController < Api::BaseController
  def index
    render json: { data: api_connection.accounts.select(:id, :name, :balance, :currency, :created_at).order(:id) }
  end
end

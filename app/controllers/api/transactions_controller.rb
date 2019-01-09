class Api::TransactionsController < Api::BaseController
  def index
    render json: { data: api_account.transactions.select(:id, :description, :amount, :currency, :made_on, :created_at).order(:id) }
  end
end

class Users::TransactionsController < Users::BaseController
  def index
    @connection   = current_user.connections.find_by(id: params[:connection_id])
    @account      = @connection.accounts.find_by(id: params[:account_id])
    @transactions = @account.transactions.order(:id)
  end
end

class Users::AccountsController < Users::BaseController
  def index
    @connection = current_user.connections.find_by(id: params[:connection_id])
    @accounts   = @connection.accounts.order(:id)
  end
end

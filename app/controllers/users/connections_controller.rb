class Users::ConnectionsController < Users::BaseController
  def index
    @connections = current_user.connections.order(id: :desc)
  end

  def create
    @connection = current_user.connections.find_by(id: params[:id])
    @connection.destroy if @connection

    redirect_back fallback_location: :root
  end

  def destroy
    @connection = current_user.connections.find_by(id: params[:id])
    if @connection
      @connection.destroy
      flash[:success] = "Connection #{@connection.name} was destroyed!"
    end
    redirect_back fallback_location: :root
  end
end

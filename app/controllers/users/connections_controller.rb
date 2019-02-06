class Users::ConnectionsController < Users::BaseController
  def index
    @connections = current_user.connections.order(id: :desc)
  end

  def create
    connection = current_user.connections.create!(name: params[:name])
    flash[:notice] = "Connection created!"

    redirect_back fallback_location: :root
  end

  def update
    @connection = current_user.connections.find_by(id: params[:id])

    if @connection
      flash[:notice] = "Connection #{@connection.name} was updated!"
      @connection.name = params[:name]

      if @connection.name.include?("generate")
        @connection.generate_data
        @connection.skip_cache_expire = true
      else
        notify_client
      end

      @connection.save!
    end

    redirect_back fallback_location: :root
  end

  def destroy
    @connection = current_user.connections.find_by(id: params[:id])

    if @connection
      @connection.destroy
      flash[:notice] = "Connection #{@connection.name} was destroyed!"
    end

    redirect_back fallback_location: :root
  end

  private

  def notify_client
    l = Logger.new("tmp/client_notify.log")
    l.info "\n\n\n"
    l.info "--------------------------------------------------------------------------------------------"
    l.info "#{@connection.updated_at} | ID: #{@connection.id} | Name: #{@connection.name}"
    l.info "--------------------------------------------------------------------------------------------"
  end
end

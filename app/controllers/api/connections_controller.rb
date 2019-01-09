class Api::ConnectionsController < Api::BaseController
  def index
    render json: { data: api_user.connections.select(:id, :name, :created_at).order(:id) }
  end

  def show
    render json: { data: api_connection.slice(:id, :name, :created_at) }
  end

  def update
    api_connection.update_attributes!(name: params[:data][:name])
    render json: { data: api_connection.slice(:id, :name, :created_at) }
  end

  def destroy
    api_connection.destroy!
    render json: { deleted: true }
  end
end

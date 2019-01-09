class Api::ConnectionsController < Api::BaseController
  def index
    render json: { data: api_user.connections.select(:id, :name, :created_at).order(:id) }
  end
end

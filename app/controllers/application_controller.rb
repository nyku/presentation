class ApplicationController < ActionController::Base
  include ShardHandler

  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    session[:user_id] = resource.id
    users_connections_path
  end
end

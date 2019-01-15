class ApplicationController < ActionController::Base
  include ShardHandler

  protect_from_forgery with: :exception

  def after_sign_in_path
    session[:user_id] = current_user.id
    users_connections_path
  end
end

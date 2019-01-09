class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def after_sign_in_path
    users_connections_path
  end
end

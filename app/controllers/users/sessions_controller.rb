class Users::SessionsController < Devise::SessionsController
  layout "application"

  def create
    lookup_user       = LookupUser.find_by(email: params[:user][:email])
    session[:user_id] = lookup_user.try(:id)

    Switch.with_master(lookup_user.try(:shard)) do
      super
    end
  end
end
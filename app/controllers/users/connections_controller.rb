class Users::ConnectionsController < Users::BaseController
  def index
    @connections = current_user.connections.order(id: :desc)
  end

  def create
    connection = current_user.connections.create!(name: params[:name])

    rand(1..5).times do
      account    = connection.accounts.create!(
        name:     "[#{connection.name}] #{Faker::Name.unique.name}",
        balance:  rand * 1000,
        currency: %W(USD EUR CAD GBP).sample
      )

    rand(1..5).times do
        account.transactions.create(
          description: "[#{connection.name}] #{Faker::Company.bs}",
          amount:      rand * 1000,
          currency:    account.currency,
          made_on:     rand(100).days.ago.to_date
        )
      end
    end

    flash[:notice] = "Connection created!"

    redirect_back fallback_location: :root
  end

  def update
    @connection = current_user.connections.find_by(id: params[:id])

    if @connection
      flash[:notice] = "Connection #{@connection.name} was updated!"
      @connection.update_attributes!(name: params[:name])
      notify_client
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

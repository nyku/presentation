module ShardHandler
  extend ActiveSupport::Concern

  included do
    around_action :with_shard
  end

  attr_reader :controller_ancestors, :shard, :connection

  def with_shard(&block)
    @controller_ancestors = self.class.ancestors
    @shard                = select_shard || Switch.master_shard
    @connection           = Switch.shards.public_send(shard.to_s).master
    print_result
    Switch.with_database(connection, &block)
  end

  private

  def select_shard
    "shard2"
    # return shard_by_api_headers if controller_ancestors.include?(Api::BaseController)
    # Tool::DatabaseManager.master_shard
  end

  def shard_by_api_headers
    LookupUser.find_by(app_id: request.headers["HTTP_APP_ID"]).try(:shard) || Switch.master_shard
  end

  def print_result
    puts "\n\n"
    puts "\e[36m========  SHARD:      #{shard}       \e[0m"
    puts "\e[35m========  CONNECTION: #{connection}  \e[0m"
    puts "\n\n"
  end
end

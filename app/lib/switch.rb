require 'ostruct'

class Switch
  class << self

    # Connect / Disconnect shards ---------------------------------------------------------
    def connect_shards!
      shards.each do |shard, databases|
        databases.each { |name, connection| connect(connection.to_sym) }
      end
    end

    def disconnect_all_shards!
      pools.each do |name, pool|
        begin
          pool.disconnect!
        rescue ActiveRecord::ConnectionNotEstablished
        end
      end
    end


    # Connect a shard ---------------------------------------------------------------------
    def connect(name)
      return if pools[name]

      configurations = ActiveRecord::Base.configurations
      spec           = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new(configurations).spec(name)

      # NOTE: we avoid creating duplicate pools to the same database
      pool = if ActiveRecord::Base.connection_pool.spec.config == spec.config
        ActiveRecord::Base.connection_pool
      else
        ActiveRecord::Base.connection_handler.establish_connection(spec.as_json)
      end

      pools[name] = pool
    end


    # Execute a query withing a database -------------------------------------------------
    def with_database(name, &block)
      original_connection = Thread.current[:_db_connection]
      pool                = pools[name.to_sym]
      result              = nil

      unless pool
        return yield original_connection
      end

      pool.with_connection do |connection|
        Thread.current[:_db_connection] = connection
        begin
          result = yield connection
        ensure
          Thread.current[:_db_connection] = original_connection
        end
      end

      result
    end


    # Execute a query withing a specific type of DB (master/slave) -----------------------
    def with_master(shard, &block)
      master = shards.send(shard.to_s).master
      with_database(master.to_sym, &block)
    end

    def with_slave(shard, &block)
      slave = shards.send(shard.to_s).slave
      with_database(slave.to_sym, &block)
    end


    # Helper methods ---------------------------------------------------------------------
    def pools
      @pools ||= {}
    end

    def shards
      Settings.sharding.send(Rails.env.to_sym).shards
    end

    def master_shard
      Settings.sharding.send(Rails.env.to_sym).master_shard
    end
  end
end

require 'ostruct'

class Switch
  Resolver = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver

  class << self
    def connect_shards!
      shards.each do |shard, databases|
        databases.each { |name, connection| connect(connection.to_sym) }
      end
    end

    def with_master(shard, &block)
      master = shards.send(shard.to_s).master
      with_database(master.to_sym, &block)
    end

    def with_slave(shard, &block)
      with_database(get_slave_database_for_shard(shard).to_sym, &block)
    end

    def get_slave_database_for_shard(shard)
      return shards.send(shard.to_s).master unless can_use_slaves?(shard)
      all_slave_databases(shard).sample
    end

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

    def connect(name)
      return if pools[name]

      configurations = ActiveRecord::Base.configurations
      spec           = Resolver.new(configurations).spec(name)

      # NOTE: we avoid creating duplicate pools to the same database
      pool = if ActiveRecord::Base.connection_pool.spec.config == spec.config
        ActiveRecord::Base.connection_pool
      else
        ActiveRecord::Base.connection_handler.establish_connection(spec.as_json)
      end

      pools[name] = pool
    end

    def pools
      @pools ||= {}
    end

    def env
      Rails.env.to_sym
    end

    def shards
      Settings.sharding.send(env).shards
    end

    def master_shard
      Settings.sharding.send(env).master_shard
    end

    def disconnect!
      pools.each do |name, pool|
        begin
          pool.disconnect!
        rescue ActiveRecord::ConnectionNotEstablished
        end
      end
    end
  end
end

class Switch
  class << self
    def with_database(name, &block)
      initial_connection_config = ActiveRecord::Base.connection.instance_variable_get(:@config)
      configurations            = Rails.configuration.database_configuration
      connection                = ActiveRecord::Base.establish_connection configurations[name.to_s]
      yield connection
    rescue
      nil
    ensure
      ActiveRecord::Base.establish_connection initial_connection_config
    end

    def with_master(shard, &block)
      master = shards.send(shard.to_s).master
      with_database(master, &block)
    end

    def masters(&block)
      shards.map do |shard, databases|
        databases["master"].to_sym
      end
    end

    def shards
      Settings.sharding.send(Rails.env.to_sym).shards
    end

    def master_shard
      Settings.sharding.send(Rails.env.to_sym).master_shard
    end
  end
end

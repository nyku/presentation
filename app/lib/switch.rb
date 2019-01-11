require 'ostruct'

class Switch
  class << self
    def with_database(name, &block)
      configurations = Rails.configuration.database_configuration
      ActiveRecord::Base.establish_connection configurations[name.to_s]
      yield
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

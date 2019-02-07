class UpdatesQueue
  attr_reader :redis

  QUEUE_NAME = "login_updates"
  BATCH_SIZE = 2

  def self.write(payload)
    Redis.new.rpush(QUEUE_NAME, payload.to_json)
  end

  def consume
    loop do
      messages = redis.lrange(QUEUE_NAME, 0, BATCH_SIZE-1)
      redis.ltrim(QUEUE_NAME, BATCH_SIZE, -1)

      if messages.any?
        consume_messages(messages)
        sleep(0.1)
      else
        sleep(1)
      end
    end
  end

  private

  def consume_messages(messages)
    payloads = messages.map(&JSON.method(:parse))

    most_recent_payload = payloads.max_by { |payload| Time.parse(payload["updated_at"]) }

    wait_until_data_is_replicated(most_recent_payload)

    payloads.each do |payload|
      connection = Connection.new(payload.except("shard"))
      connection.expire_cache
      connection.notify_client
    end
  end

  def wait_until_data_is_replicated(payload)
    connection_id         = payload["id"]
    connection_updated_at = payload["updated_at"]
    shard                 = payload["shard"]

    DatabaseHandler.with_slave(shard) do
      until slave_synced?(connection_id, connection_updated_at, shard)
        sleep(1)
      end
    end
  end

  def slave_synced?(connection_id, master_connection_updated_at, shard)
    connection = Connection.find_by(id: connection_id)
    return false unless connection
    connection.updated_at >= master_connection_updated_at
  end

  def redis
    @redis ||= Redis.new
  end
end
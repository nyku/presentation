class LookupUser < ApplicationRecord
  def self.get_shard(attribute, value)
    Rails.cache.fetch("lookup_user_shard:#{attribute}:#{value}", expires_in: 24.hours) do
      find_by(attribute => value).try(:shard) || DatabaseHandler.master_shard
    end
  end
end

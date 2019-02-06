class LookupUser < ApplicationRecord
  after_save    :expire_cache, :create_cache
  after_destroy :expire_cache

  def self.get_shard(attribute, value)
    Rails.cache.fetch("lookup_user_shard:#{attribute}:#{value}", expires_in: 24.hours) do
      find_by(attribute => value).try(:shard) || DatabaseHandler.master_shard
    end
  end

  private

  def create_cache
    cache_keys.each { |cache_key| Rails.cache.fetch(cache_key, expires_id: 24.hours) { shard } }
  end

  def expire_cache
    cache_keys.each { |cache_key| Rails.cache.delete(cache_key) }
  end

  def cache_keys
    ["lookup_user_shard:email:#{email}", "lookup_user_shard:app_id:#{app_id}"]
  end
end

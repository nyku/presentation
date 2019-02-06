class Connection < ApplicationRecord
  belongs_to :user
  has_many :accounts, dependent: :destroy

  after_save    :expire_cache, :create_cache
  after_destroy :expire_cache

  private

  def create_cache
    Rails.cache.fetch(cache_key, expires_id: 24.hours) { self }
  end

  def expire_cache
    Rails.cache.delete(cache_key)
  end

  def cache_key
    "api_connection:#{user_id}:#{id}"
  end
end

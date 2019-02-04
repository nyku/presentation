class Connection < ApplicationRecord
  belongs_to :user
  has_many :accounts, dependent: :destroy

  after_update :expire_cache
  after_destroy :expire_cache

  private

  def expire_cache
    Rails.cache.delete("api_connection:#{id}")
  end
end

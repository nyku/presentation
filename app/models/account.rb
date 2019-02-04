class Account < ApplicationRecord
  belongs_to :connection
  has_many :transactions, dependent: :destroy

  after_update  :expire_cache
  after_destroy :expire_cache

  private

  def expire_cache
    Rails.cache.delete("api_account:#{id}")
  end
end

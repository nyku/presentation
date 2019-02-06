class Connection < ApplicationRecord
  attr_accessor :skip_cache_expire

  belongs_to :user
  has_many :accounts, dependent: :destroy

  after_save    :expire_cache, :create_cache
  after_destroy :expire_cache

  def generate_data
    return if accounts.any?

    rand(1..5).times do
      account = accounts.create!(
        name:     "[#{name}] #{Faker::Name.unique.name}",
        balance:  rand * 1000,
        currency: %W(USD EUR CAD GBP).sample
      )

    rand(1..5).times do
        account.transactions.create(
          description: "[#{name}] #{Faker::Company.bs}",
          amount:      rand * 1000,
          currency:    account.currency,
          made_on:     rand(100).days.ago.to_date
        )
      end
    end
  end

  private

  def create_cache
    Rails.cache.fetch(cache_key, expires_id: 24.hours) { self }
  end

  def expire_cache
    Rails.cache.delete(cache_key) unless skip_cache_expire
  end

  def cache_key
    "api_connection:#{user_id}:#{id}"
  end
end

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :connections, dependent: :destroy

  before_create :generate_secrets

  private

  def generate_secrets
    self.app_id = SecureRandom.hex
    self.secret = SecureRandom.hex
  end
end

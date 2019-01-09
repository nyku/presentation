class Account < ApplicationRecord
  belongs_to :connection
  has_many :transactions, dependent: :destroy
end

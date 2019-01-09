class Connection < ApplicationRecord
  belongs_to :user
  has_many :accounts, dependent: :destroy
end

Devise.setup do |config|
  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'
  require 'devise/orm/active_record'
  config.case_insensitive_keys = [:email]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 11
  config.reconfirmable = true
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete
end

module Devise
  module Models
    module Authenticatable
      module ClassMethods
        def serialize_from_session(key, salt)
          user_shard = DatabaseHandler.with_master(DatabaseHandler.master_shard) do
            LookupUser.find_by(id: key).try(:shard) || DatabaseHandler.master_shard
          end

          record = DatabaseHandler.with_master(user_shard) do
            User.find_by(id: key)
          end

          record if record && record.authenticatable_salt == salt
        end
      end
    end
  end
end

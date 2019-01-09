Switch.connect_shards!
# module ActiveRecord
#   class Migration
#     def migrate(direction)
#       return unless respond_to?(direction)

#       case direction
#       when :up   then announce "migrating"
#       when :down then announce "reverting"
#       end

#       time = Benchmark.measure do
#         exec_migration(ActiveRecord::Base.connection, direction)
#       end

#       case direction
#       # rubocop:disable Style/FormatString
#       when :up   then announce "migrated (%.4fs)" % time.real; write
#       when :down then announce "reverted (%.4fs)" % time.real; write
#       end
#     end
#   end

#   class Migrator
#     def execute_migration_in_transaction(migration, direction)
#       ddl_transaction(migration) do
#         @direction = direction
#         migration.migrate(direction)
#         record_version_state_after_migrating(migration.version)
#       end
#     end

#     def migrate
#       if !target && @target_version && @target_version > 0
#         raise UnknownMigrationVersionError.new(@target_version)
#       end

#       @migrated_shards = []
#       runnable.each do |migration|
#         Base.logger.info "Migrating to #{migration.name} (#{migration.version})" if Base.logger

#         Switch.masters.each do |connection_name|
#           Switch.with_database(connection_name) do |connection|
#             ActiveRecord::SchemaMigration.create_table

#             begin
#               execute_migration_in_transaction(migration, @direction)
#               @migrated_shards << connection_name
#             rescue => e
#               @migrated_shards.each do |connection_name|
#                 Switch.with_database(connection_name) do |connection|
#                   opposite_direction = { up: :down, down: :up }
#                   execute_migration_in_transaction(migration, opposite_direction[@direction])
#                 end
#               end
#               canceled_msg = use_transaction?(migration) ? "this and " : ""
#               # rubocop:disable Style/RaiseArgs
#               raise StandardError, "An error has occurred, #{canceled_msg}all later migrations canceled:\n\n#{e}", e.backtrace
#             end
#           end
#         end
#       end
#     end
#   end
# end
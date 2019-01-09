class SequenceUpdater
  def self.run(sequence_bump=1000)
    masters   = Switch.masters
    sequences = {}

    masters.each do |master|
      shard_sequences = ActiveRecord::Base.connection.execute(%Q{
        select nextval('users_id_seq')        as users_id,
               nextval('connections_id_seq')  as connections_id,
               nextval('accounts_id_seq')     as accounts_id,
               nextval('transactions_id_seq') as transactions_id
      }).to_a.reduce({}, :merge)

      shard_sequences.merge!(shard_sequences) { |_, _, v| v.to_i }
      sequences.merge!(shard_sequences) { |k, b_value, a_value| [a_value.to_i, b_value.to_i].max }
    end

    masters.each_with_index do |master, index|
      Switch.with_database(master) do
        ActiveRecord::Base.connection.execute(%Q{
          ALTER SEQUENCE users_id_seq        INCREMENT BY #{masters.count} RESTART WITH #{sequence_bump+index+1+sequences['users_id'].to_i};
          ALTER SEQUENCE connections_id_seq  INCREMENT BY #{masters.count} RESTART WITH #{sequence_bump+index+1+sequences['connections_id'].to_i};
          ALTER SEQUENCE accounts_id_seq     INCREMENT BY #{masters.count} RESTART WITH #{sequence_bump+index+1+sequences['accounts_id'].to_i};
          ALTER SEQUENCE transactions_id_seq INCREMENT BY #{masters.count} RESTART WITH #{sequence_bump+index+1+sequences['transactions_id'].to_i};
        })
      end
    end
  end
end
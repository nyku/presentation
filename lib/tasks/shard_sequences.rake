namespace :shard_sequences do
  desc "Update shard sequences"

  task update: :environment do
    SequenceUpdater.run
  end
end

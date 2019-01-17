loop do
  `pgsync --db shard1`
  `pgsync --db shard2`
  sleep 1
end
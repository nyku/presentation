# README

### Setup

0. Drop all databases

```sh
rake db:drop
DB=presentation_development2       rake db:drop
DB=presentation_development_slave  rake db:drop
DB=presentation_development2_slave rake db:drop
```

1. Create database

```sh
rake db:create
```

2. Create shard 1 slave, shard 2 master, shard 2 slave

```sh
DB=presentation_development_slave  rake db:create
DB=presentation_development2       rake db:create
DB=presentation_development2_slave rake db:create
```

3. Run migrations (on all masters)

```sh
rake db:migrate
```

4. Replicate schema (on all slaves)

```sh
pg_dump --schema-only -U test -h localhost -W presentation_development  | psql presentation_development_slave  -U test -W -h localhost
pg_dump --schema-only -U test -h localhost -W presentation_development2 | psql presentation_development2_slave -U test -W -h localhost
```

5. Update sequences

```sh
rake shard_sequences:update
```

6. Simulate replication between masters/slaves (optional)

```sh
ruby tmp/sync.sh
```

7. Run the application

```sh
rails s
```

8. Sign up

http://localhost:3000/users/sign_up
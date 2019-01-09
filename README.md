# README

### Implementing Sharding

1. Create second shard database

```sh
DB=presentation_development2 rake db:create
```

2. Replicate schema

```sh
pg_dump --schema-only -U test -h localhost -W presentation_development | psql presentation_development2 -U test -W -h localhost
```


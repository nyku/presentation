# README

### Setup

1. Update `config/database.yml`

```yaml
username: YOUR_PG_USERNAME
password: YOUR_PG_PASSWORD
```

2. Update `.pgsync-shard1.yml`, `.pgsync-shard2.yml` (Optional)

```yaml
from: postgres://YOUR_PG_USERNAME:YOUR_PG_PASSWORD@localhost:5432/presentation_development
to: postgres://YOUR_PG_USERNAME:YOUR_PG_PASSWORD@localhost:5432/presentation_development_slave
```

```yaml
from: postgres://YOUR_PG_USERNAME:YOUR_PG_PASSWORD@localhost:5432/presentation_development2
to: postgres://YOUR_PG_USERNAME:YOUR_PG_PASSWORD@localhost:5432/presentation_development2_slave
```

3. Drop all databases (Optional)

```sh
rake db:drop
DB=presentation_development2       rake db:drop
DB=presentation_development_slave  rake db:drop
DB=presentation_development2_slave rake db:drop
```

4. Create database

```sh
rake db:create
```

5. Create shard 1 slave, shard 2 master, shard 2 slave

```sh
DB=presentation_development_slave  rake db:create
DB=presentation_development2       rake db:create
DB=presentation_development2_slave rake db:create
```

6. Run migrations (on all masters)

```sh
rake db:migrate
```

7. Replicate schema (on all slaves)

```sh
pg_dump --schema-only -U YOUR_PG_USERNAME -h localhost -W presentation_development  | psql presentation_development_slave  -U YOUR_PG_USERNAME -W -h localhost
pg_dump --schema-only -U YOUR_PG_USERNAME -h localhost -W presentation_development2 | psql presentation_development2_slave -U YOUR_PG_USERNAME -W -h localhost
```

8. Update sequences

```sh
rake shard_sequences:update
```

9. Simulate replication between masters/slaves (optional)

```sh
ruby app/lib/sync.rb
```

10. Run the application

```sh
rails s
```

11. Sign up

http://localhost:3000/users/sign_up


--------------------------

### API

Authentication headers:

| Header       | DB field       |
|--------------|----------------|
| `App-Id`     | `User.app_id`  |
| `App-Secret` | `User.secret`  |


Routes:

| Name              | Route                                                                                              |
|-------------------|----------------------------------------------------------------------------------------------------|
| List connections  | **GET** http://localhost:3000/api/connections                                                      |
| Show connection   | **GET** http://localhost:3000/api/connections/:id                                                  |
| Update connection | **PUT** http://localhost:3000/api/connections/:id             `{ "data": { "name": "updated" }}`   |
| Delete connection | **DELETE** http://localhost:3000/api/connections/:id                                               |
| List accounts     | **GET** http://localhost:3000/api/accounts?connection_id=:id                                       |
| List transactions | **GET** http://localhost:3000/api/transactions?connection_id=:connection_id&account_id=:account_id |

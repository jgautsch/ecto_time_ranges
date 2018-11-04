# PostgreSQL/Postgrex/Ecto Time Ranges - Bug Demo

This is a repo to demonstrate a possible bug somewhere in either `postgrex` or `ecto_sql`.

This project contains a `time_blocks` table with `tz_time_range` and `time_range` columns, with Postgres [types of `tztsrange` and `tsrange`](https://www.postgresql.org/docs/9.3/static/rangetypes.html) respectively.

The project defines custom types for these column types, found in `lib/ranges/extensions/` and represent both `tsrange` and `tztsrange` as tuples of `{start, finish}`.

Tests pass with `postgrex 0.13.5` and `ecto 2.2.11`, but fail with `postgrex 0.14.0` and `ecto 2.2.11`.

Specifically, the tests fail when trying to insert a `tstzrange` with `DateTime` values. It seems that they're being cast to `NaiveDateTimes` somehwere in the new library versions, which results in the following error:

```
** (DBConnection.EncodeError) Postgrex expected %DateTime{}, got ~N[2018-11-04 09:00:00]. Please make sure the value you are passing matches the definition in your table or in your query or convert the value accordingly.
code: time_block = time_block_factory(attrs)
stacktrace:
  (postgrex) lib/postgrex/type_module.ex:713: Postgrex.DefaultTypes.encode_value/2
  (postgrex) lib/postgrex/type_module.ex:713: Postgrex.DefaultTypes.encode_params/3
  (postgrex) lib/postgrex/query.ex:62: DBConnection.Query.Postgrex.Query.encode/3
  (db_connection) lib/db_connection.ex:1074: DBConnection.encode/5
  (db_connection) lib/db_connection.ex:1172: DBConnection.run_prepare_execute/5
  (db_connection) lib/db_connection.ex:1268: DBConnection.run/6
  (db_connection) lib/db_connection.ex:480: DBConnection.parsed_prepare_execute/5
  (db_connection) lib/db_connection.ex:473: DBConnection.prepare_execute/4
  (postgrex) lib/postgrex.ex:167: Postgrex.query/4
  (ecto_sql) lib/ecto/adapters/sql.ex:627: Ecto.Adapters.SQL.struct/10
  (ecto) lib/ecto/repo/schema.ex:603: Ecto.Repo.Schema.apply/4
```

## Run it

The tests illustrate the possible bug between `ecto_sql 3.0.0/postgrex 0.14.0` and `ecto 2.2.11/postgrex 0.13.5`.

NOTE: `mix deps.reinstall` is defined in `mix.exs` to clean, re-get, and compile dependencies, and `mix test` automatically creates and migrates the database.

### PASSING TESTS: Run with `ecto 2.2.11/postgrex 0.13.5`

1. Uncomment/comment out relevant lines in `mix.exs`:

```elixir
defp deps do
  [
    # For New Versions:
    # {:ecto_sql, "3.0.0"},
    # {:postgrex, "0.14.0"}

    # For Old Versions:
    {:ecto, "2.2.11"},
    {:postgrex, "0.13.5"}
  ]
end
```

2. Reinstall dependencies and run tests:

```bash
$ mix deps.reinstall
$ mix test
```

### FAILING TESTS: Run with `ecto_sql 3.0.0/postgrex 0.14.0`

1. Uncomment/comment out relevant lines in `mix.exs`:

```elixir
defp deps do
    [
      # For New Versions:
      {:ecto_sql, "3.0.0"},
      {:postgrex, "0.14.0"}

      # For Old Versions:
      # {:ecto, "2.2.11"},
      # {:postgrex, "0.13.5"}
    ]
  end
```

2. Reinstall dependencies and run tests:

```bash
$ mix deps.reinstall
$ mix test
```

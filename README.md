# PostgreSQL/Postgrex/Ecto Time Ranges

This is a repo to demonstrate usage of `tsrange` and `tstzrange` Postgres column types with elixir and ecto.

This project contains a `time_blocks` table with `tz_time_range` and `time_range` columns, with Postgres [types of `tztsrange` and `tsrange`](https://www.postgresql.org/docs/9.3/static/rangetypes.html) respectively.

The project defines custom types for these column types, found in `lib/ranges/extensions/` and represent both `tsrange` and `tztsrange` as tuples of `{start, finish}`.

Check out `test/ranges/time_block_test.exs` for usage.

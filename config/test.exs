use Mix.Config

config :ranges, Ranges.Repo,
  database: "ranges_repo_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

use Mix.Config

config :ranges, Ranges.Repo,
  database: "ranges_repo_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

defmodule Ranges.Repo do
  use Ecto.Repo,
    otp_app: :ranges,
    adapter: Ecto.Adapters.Postgres
end

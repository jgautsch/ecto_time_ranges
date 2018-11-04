defmodule Ranges.MixProject do
  use Mix.Project

  def project do
    [
      app: :ranges,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Ranges.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # For New Versions:
      {:ecto_sql, "3.0.0"},
      {:postgrex, "0.14.0"}

      # For Old Versions:
      # {:ecto, "2.2.11"},
      # {:postgrex, "0.13.5"}

      # For New Versions (local paths):
      # {:ecto_sql, "3.0.0", path: "~/Downloads/ecto_sql-3.0.0/", override: true},
      # {:ecto, "3.0.1", path: "~/Downloads/ecto-3.0.1/", override: true},
      # {:postgrex, "0.14.0", path: "~/Downloads/postgrex-0.14.0/", override: true}
    ]
  end

  defp aliases do
    [
      "deps.reinstall": [
        "deps.unlock --all",
        "deps.clean --all",
        "deps.get",
        "deps.compile"
      ],
      "ecto.setup": [
        "ecto.create",
        "ecto.migrate"
      ],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end

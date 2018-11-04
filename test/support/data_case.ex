defmodule Ranges.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Ranges.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Ranges.DataCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Ranges.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Ranges.Repo, {:shared, self()})
    end

    :ok
  end
end

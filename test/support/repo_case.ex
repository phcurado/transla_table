defmodule TranslaTable.RepoCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  using do
    quote do
      alias TranslaTable.Repo

      import Ecto
      import Ecto.Query
      import TranslaTable.RepoCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(TranslaTable.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(TranslaTable.Repo, {:shared, self()})
    end

    :ok
  end
end

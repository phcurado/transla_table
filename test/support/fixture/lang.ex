defmodule TranslaTable.Fixture.Lang do
  @moduledoc false

  alias TranslaTable.Fixture.Schema.Lang
  alias TranslaTable.Repo

  def insert(attrs) when is_map(attrs) do
    struct!(Lang, attrs)
    |> Repo.insert!()
  end

  def seed() do
    english = insert(%{name: "English"})
    portuguese = insert(%{name: "Portuguese"})
    %{
      lang:
      %{
        en: english,
        pt: portuguese
      }
    }
  end
end

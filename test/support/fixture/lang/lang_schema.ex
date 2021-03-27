defmodule TranslaTable.Fixture.Schema.Lang do
  @moduledoc false

  use Ecto.Schema

  schema "language" do
    field :name, :string
  end
end

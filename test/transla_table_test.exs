defmodule TranslaTableTest do
  use ExUnit.Case
  doctest TranslaTable

  defmodule TestSchema do
    use Ecto.Schema

    schema "test_schema" do
      field :name, :string
      field :description, :string
      field :author, :string
      field :slug, :string

      timestamps()
    end

    @doc false
    def changeset(test_schema, attrs) do
      test_schema
      |> cast(attrs, [:name, :description, :author, :slug])
    end

  end

  # test "greets the world" do
  #   assert TranslaTable.hello() == :world
  # end
end

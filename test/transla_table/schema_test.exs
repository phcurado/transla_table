defmodule TranslaTable.SchemaTest do
  use ExUnit.Case

  alias TranslaTable.Schema

  defmodule EctoSchema do
    use Ecto.Schema
    schema "ecto_schema" do
      field :name, :string
      field :description, :string
      field :author, :string
      field :slug, :string

      belongs_to :account, TranslaTable.SchemaTest.EctoRelationSchema
    end
  end

  defmodule EctoRelationSchema do
    use Ecto.Schema

    @primary_key {:id_legacy, :binary_id, []}
    schema "ecto_relation_schema" do
      field :name, :string
      field :description, :string
      field :author, :string
      field :slug, :string
    end
  end

  defmodule NoEctoSchema, do: nil

  test "Assert valid arguments" do
    assert {
      {EctoSchema, :id},
      :ecto_schema,
      [{:name, :string}],
      {TranslaTable.Lang, :id}
    } = Schema.compile_args([module: EctoSchema, fields: [:name]])
  end

  test "Assert custom Module arguments" do
    assert {
      {EctoRelationSchema, :binary_id},
      :ecto_relation_schema,
      [{:name, :string}, {:description, :string}],
      {TranslaTable.Lang, :id}
    } = Schema.compile_args([module: EctoRelationSchema, fields: [:name, :description]])
  end

  test "Invalid Ecto key :user field" do
    assert_raise ArgumentError, "invalid :user key in Schema fields", fn ->
      Schema.compile_args([module: EctoSchema,fields: [:user]])
    end

    assert_raise ArgumentError, "invalid :user key in Schema fields", fn ->
      Schema.compile_args([module: EctoSchema, fields: [:name, :user]])
    end
  end

  test "Invalid Ecto key field" do
    assert_raise KeyError, fn ->
      Schema.compile_args([])
    end
  end

  test "Invalid Ecto module" do
    assert_raise ArgumentError, "invalid Ecto module", fn ->
      Schema.compile_args([module: NoEctoSchema])
    end
  end
end

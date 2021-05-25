defmodule TranslaTable.Schema.EctoTest do
  use ExUnit.Case

  alias TranslaTable.Schema.Ecto, as: EctoSchema
  alias TranslaTable.Fixture.Schema.Lang

  defmodule GenericSchema do
    use Ecto.Schema

    schema "generic_schema" do
      field :name, :string
      field :description, :string
      field :author, :string
      field :slug, :string

      belongs_to :account, TranslaTable.SchemaTest.GenericSchemaRelationSchema
    end
  end

  defmodule GenericSchemaRelationSchema do
    use Ecto.Schema

    @primary_key {:id_legacy, :binary_id, []}
    schema "generic_relation_schema" do
      field :name, :string
      field :description, :string
      field :author, :string
      field :slug, :string
    end
  end

  defmodule NoEctoSchema, do: nil

  test "Assert valid arguments" do
    assert {
             {GenericSchema, :id},
             :generic_schema,
             [{:name, :string}],
             {Lang, :id}
           } = EctoSchema.compile_args(module: GenericSchema, fields: [:name])
  end

  test "Assert custom Module arguments" do
    assert {
             {GenericSchemaRelationSchema, :binary_id},
             :generic_relation_schema,
             [{:name, :string}, {:description, :string}],
             {Lang, :id}
           } =
             EctoSchema.compile_args(
               module: GenericSchemaRelationSchema,
               fields: [:name, :description]
             )
  end

  test "Invalid Ecto key :user field" do
    assert_raise ArgumentError, "invalid :user key in Schema fields", fn ->
      EctoSchema.compile_args(module: GenericSchema, fields: [:user])
    end

    assert_raise ArgumentError, "invalid :user key in Schema fields", fn ->
      EctoSchema.compile_args(module: GenericSchema, fields: [:name, :user])
    end
  end

  test "Invalid Ecto key field" do
    assert_raise KeyError, fn ->
      EctoSchema.compile_args([])
    end
  end

  test "Invalid Ecto module" do
    assert_raise ArgumentError, "invalid Ecto module", fn ->
      EctoSchema.compile_args(module: NoEctoSchema)
    end
  end
end

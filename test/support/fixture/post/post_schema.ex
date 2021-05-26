defmodule TranslaTable.Fixture.Schema.Post do
  @moduledoc false

  use Ecto.Schema

  use TranslaTable.Schema,
    translation_schema: TranslaTable.Fixture.Schema.PostTranslation

  import Ecto.Changeset

  schema "post" do
    field :title, :string
    field :description, :string
    field :author, :string
    field :slug, :string

    has_many_translations()

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :description, :author, :slug])
    |> cast_translation()
  end
end

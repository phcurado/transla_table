defmodule TranslaTable.Fixture.Schema.Post do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  import TranslaTable

  alias TranslaTable.Fixture.Schema.PostTranslation

  schema "post" do
    field :title, :string
    field :description, :string
    field :author, :string
    field :slug, :string

    has_many_translations(PostTranslation)

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :description, :author, :slug])
    |> cast_translation(PostTranslation)
  end
end

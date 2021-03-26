defmodule TranslaTableTest do
  use TranslaTable.RepoCase
  doctest TranslaTable

  @new_post %{
    title: "Blog post",
    description: "Description",
  }

  defmodule Post do
    use Ecto.Schema
    import Ecto.Changeset
    import TranslaTable

    alias TranslaTableTest.PostTranslation

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

  defmodule PostTranslation do
    use TranslaTable,
      module: TranslaTableTest.Post,
      fields: [:title, :description, :slug]
  end

  test "add post with translation" do
    # Post.changeset(%Post{}, @new_post)
    # |> Repo.insert!()

    # |> IO.inspect()
    # assert TranslaTable.hello() == :world
  end
end

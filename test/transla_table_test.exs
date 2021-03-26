defmodule TranslaTableTest do
  use TranslaTable.RepoCase
  doctest TranslaTable

  @new_post %{
    title: "Blog Post",
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

  test "add post with translation", %{en: en, pt: pt} do
    post_with_translations = Map.put(@new_post, :translations, [
      %{
        language_id: pt.id,
        title: "Post do Blog",
        description: "Descrição"
      },
      %{
        language_id: en.id,
        title: "Blog Post",
        description: "Description"
      }
    ])

    post = %Post{}
           |> Post.changeset(post_with_translations)
           |> Repo.insert!()

    assert post.description == "Description"
    assert post.title == "Blog Post"

    en_translation = Enum.find(post.translations, &(&1.language_id == en.id))
    assert en_translation.title == "Blog Post"
    assert en_translation.description == "Description"

    pt_translation = Enum.find(post.translations, &(&1.language_id == pt.id))
    assert pt_translation.title == "Post do Blog"
    assert pt_translation.description == "Descrição"
  end

  setup do
    english = Repo.insert!(%TranslaTable.Lang{name: "English"})
    portuguese = Repo.insert!(%TranslaTable.Lang{name: "Portuguese"})
    %{en: english, pt: portuguese}
  end
end

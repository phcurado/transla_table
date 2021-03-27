defmodule TranslaTableTest do
  use TranslaTable.RepoCase
  alias TranslaTable.Fixture.{Post, Lang}

  doctest TranslaTable

  @new_post %{
    title: "Blog Post",
    description: "Description",
  }

  setup [:seed_lang]

  test "add post with translation", %{lang: lang} do
    %{en: en, pt: pt} = lang
    post_attrs = Map.put(@new_post, :translations, [
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

    post = Post.insert(post_attrs)

    assert post.description == "Description"
    assert post.title == "Blog Post"

    en_translation = Enum.find(post.translations, &(&1.language_id == en.id))
    assert en_translation.title == "Blog Post"
    assert en_translation.description == "Description"

    pt_translation = Enum.find(post.translations, &(&1.language_id == pt.id))
    assert pt_translation.title == "Post do Blog"
    assert pt_translation.description == "Descrição"
  end

  defp seed_lang(_context), do: Lang.seed()
end

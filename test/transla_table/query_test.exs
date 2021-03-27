defmodule TranslaTable.QueryTest do
  use ExUnit.Case
  import Ecto.Query
  use TranslaTable.RepoCase
  alias TranslaTable.Fixture.{Post, Lang}
  alias TranslaTable.Fixture.Schema.Post, as: PostSchema
  alias TranslaTable.Fixture.Schema.PostTranslation, as: PostTranslationSchema
  import TranslaTable.Query


  setup [:seed_lang, :seed_post]

  test "Assert valid arguments", %{lang: lang} do
    %{pt: pt, en: en} = lang
    query = from q in PostSchema

    post_pt = query
    |> localize_query(pt.id, PostTranslationSchema)
    |> Repo.one()

    assert post_pt.title == "Post do Blog"
    assert post_pt.description == "Descrição"

    post_en = query
    |> localize_query(en.id, PostTranslationSchema)
    |> Repo.one()

    assert post_en.title == "Blog Post"
    assert post_en.description == "Description"
  end

  defp seed_post(%{lang: %{en: en, pt: pt}}), do: Post.seed_with_lang(en.id, pt.id)

  defp seed_lang(_context), do: Lang.seed()
end

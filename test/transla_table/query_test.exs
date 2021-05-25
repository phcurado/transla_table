defmodule TranslaTable.QueryTest do
  use ExUnit.Case
  import Ecto.Query
  use TranslaTable.RepoCase
  alias TranslaTable.Fixture.{Post, Lang}
  alias TranslaTable.Fixture.Schema.Post, as: PostSchema
  alias TranslaTable.Fixture.Schema.PostTranslation, as: PostTranslationSchema
  import TranslaTable.Query

  describe "Setup translations on schema" do
    setup [:seed_lang, :seed_post_with_lang]

    test "Get fields on schema", %{lang: lang} do
      %{pt: pt, en: en} = lang
      query = from(q in PostSchema)

      post_pt =
        query
        |> localize_query(pt.id, PostTranslationSchema)
        |> Repo.one()

      assert post_pt.title == "Post do Blog"
      assert post_pt.description == "Descrição"

      post_en =
        query
        |> localize_query(en.id, PostTranslationSchema)
        |> Repo.one()

      assert post_en.title == "Blog Post"
      assert post_en.description == "Description"
    end

    test "Get fields on schema after query", %{lang: lang} do
      %{pt: pt, en: en} = lang
      query = from(q in PostSchema)

      query_by_title = fn query, %{title: title, locale: _} ->
        from [p, translations: tr] in query,
          where: not is_nil(tr.title) and ilike(tr.title, ^("%" <> title <> "%")),
          or_where: not is_nil(p.title) and ilike(p.title, ^("%" <> title <> "%"))
      end

      post_pt =
        query
        |> localize_query(pt.id, PostTranslationSchema)
        |> query_by_title.(%{title: "Post do Blog", locale: pt.id})
        |> Repo.one()

      assert post_pt.title == "Post do Blog"
      assert post_pt.description == "Descrição"

      post_en =
        query
        |> localize_query(en.id, PostTranslationSchema)
        |> query_by_title.(%{title: "Post do Blog", locale: en.id})
        |> Repo.one()

      assert post_en == nil
    end
  end

  describe "Schema without translations" do
    setup [:seed_lang, :seed_post]

    test "Get fields on schema", %{lang: lang} do
      %{pt: pt, en: en} = lang
      query = from(q in PostSchema)

      post_pt =
        query
        |> localize_query(pt.id, PostTranslationSchema)
        |> Repo.one()

      assert post_pt.title == "Blog Post"
      assert post_pt.description == "Description"

      post_en =
        query
        |> localize_query(en.id, PostTranslationSchema)
        |> Repo.one()

      assert post_en.title == "Blog Post"
      assert post_en.description == "Description"
    end

    test "Get fields on schema after query", %{lang: lang} do
      %{pt: pt, en: en} = lang
      query = from(q in PostSchema)

      query_by_title = fn query, %{title: title, locale: _} ->
        from [p, translations: tr] in query,
          where: not is_nil(tr.title) and ilike(tr.title, ^("%" <> title <> "%")),
          or_where: not is_nil(p.title) and ilike(p.title, ^("%" <> title <> "%"))
      end

      post_pt =
        query
        |> localize_query(pt.id, PostTranslationSchema)
        |> query_by_title.(%{title: "Post", locale: pt.id})
        |> Repo.one()

      assert post_pt.title == "Blog Post"
      assert post_pt.description == "Description"

      post_en =
        query
        |> localize_query(en.id, PostTranslationSchema)
        |> query_by_title.(%{title: "Post", locale: pt.id})
        |> Repo.one()

      assert post_en.title == "Blog Post"
      assert post_en.description == "Description"
    end
  end

  defp seed_post(_context), do: Post.seed()

  defp seed_post_with_lang(%{lang: %{en: en, pt: pt}}), do: Post.seed_with_lang(en.id, pt.id)

  defp seed_lang(_context), do: Lang.seed()
end

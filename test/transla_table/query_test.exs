defmodule TranslaTable.QueryTest do
  use TranslaTable.RepoCase
  import Ecto.Query
  import TranslaTable.Query

  alias TranslaTable.Fixture.Lang
  alias TranslaTable.Fixture.Post

  alias TranslaTable.Fixture.Schema.Post, as: PostSchema
  alias TranslaTable.Fixture.Schema.PostTranslation, as: PostTranslationSchema

  describe "Setup translations on schema" do
    defmodule PostContext do
      import Ecto.Query
      import TranslaTable.Query

      alias TranslaTable.Fixture.Schema.Post

      def list_all() do
        from(p in Post)
        |> preload(:translations)
        |> Repo.all()
      end

      def list_localized(locale_id) do
        from(p in Post)
        |> localize_query(locale_id)
        |> Repo.all()
      end
    end

    setup [:seed_lang, :seed_post_with_lang]

    test "With query module", %{lang: lang} do
      %{pt: pt, en: en} = lang

      assert [
               %PostSchema{
                 description: "Description",
                 title: "Blog Post",
                 translations: [
                   %PostTranslationSchema{
                     description: "Description",
                     title: "Blog Post"
                   },
                   %PostTranslationSchema{
                     description: "Descrição",
                     title: "Post do Blog"
                   }
                 ]
               }
             ] = PostContext.list_all()

      assert [
               %PostSchema{
                 description: "Description",
                 title: "Blog Post"
               }
             ] = PostContext.list_localized(en.id)

      assert [
               %PostSchema{
                 description: "Descrição",
                 title: "Post do Blog"
               }
             ] = PostContext.list_localized(pt.id)
    end

    test "Get fields on schema", %{lang: lang} do
      %{pt: pt, en: en} = lang
      query = from(q in PostSchema)

      post_pt =
        query
        |> localize_query(pt.id)
        |> Repo.one()

      assert post_pt.title == "Post do Blog"
      assert post_pt.description == "Descrição"

      post_en =
        query
        |> localize_query(en.id)
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
        |> localize_query(pt.id)
        |> query_by_title.(%{title: "Post do Blog", locale: pt.id})
        |> Repo.one()

      assert post_pt.title == "Post do Blog"
      assert post_pt.description == "Descrição"

      post_en =
        query
        |> localize_query(en.id)
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
        |> localize_query(pt.id)
        |> Repo.one()

      assert post_pt.title == "Blog Post"
      assert post_pt.description == "Description"

      post_en =
        query
        |> localize_query(en.id)
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
        |> localize_query(pt.id)
        |> query_by_title.(%{title: "Post", locale: pt.id})
        |> Repo.one()

      assert post_pt.title == "Blog Post"
      assert post_pt.description == "Description"

      post_en =
        query
        |> localize_query(en.id)
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

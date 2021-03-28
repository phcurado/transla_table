defmodule TranslaTable.Query do
  @moduledoc """
  Query helper when dealing internationalized data.
  """

  @doc """
  Create a query to localize an entity from database.

  ## Example
    You can create your own functions for composing queries.

      defmodule MyApp.Blog.Post do
        import Ecto.Query
        import TranslaTable.Query
        alias MyApp.{Post, PostTranslation}
        alias MyApp.Repo

        def run(filters) do
          base_query()
          |> localize_query(filters["locale"], PostTranslation)
          |> filter_by_title(filters)
          |> Repo.all()
        end

        def base_query() do
          from b in Post
        end

        def filter_by_title(query, %{title: title}) do
          from b in query,
          where: title == ^title
        end

        def filter_by_title(query, _), do: query
      end

    The run method will return your data translated based on the `locale` passed in the filters.
    This `locale` parameter should be the reference id of your Language table.

    The method `filter_by_title`, it is not filtering by the localized value.
    If you want all your filters to be localized, It's recomended to structure your module in this way:

      defmodule MyApp.Blog.Post do
        import Ecto.Query
        import TranslaTable.Query
        alias MyApp.{Post, PostTranslation}
        alias MyApp.Repo

        def run(filters) do
          base_query()
          |> localize(filters)
          |> filter_by_title(filters)
          |> Repo.all()
        end

        def base_query() do
          from b in Post
        end

        def localize(query, %{locale: locale}) do
          localize_query(query, locale, PostTranslation)
        end

        def localize(query, _params), do: query

        def filter_by_title(query, %{title: title, locale: _}) do
          from [translations: tr] in query, # This is the name binding to the translations join
          where: tr.title == ^title
        end

        # This will be the default method when the locale is not added as an argument
        def filter_by_title(query, %{title: title}) do
          from b in query,
          where: title == ^title
        end

        def filter_by_title(query, _), do: query
      end

    This way the queries are composable by locale and It's flexible enough for not using the locale argument at all.
  """
  defmacro localize_query(query, locale_id, translation_module) do
    quote bind_quoted: [query: query, locale_id: locale_id, translation_module: translation_module] do
      fields = translation_module.__trans_schema__(:fields)
      foreign_id = translation_module.__trans_schema__(:table_foreign_id)

      from q in query,
      left_join: tm in ^translation_module, as: :translations, on: q.id == field(tm, ^foreign_id) and tm.language_id == ^locale_id,
      select_merge:  map(tm, ^fields)
    end
  end
end

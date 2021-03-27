defmodule TranslaTable.Query do
  @moduledoc """
  This module define some helpers when dealing with query that must return de data internationalized.
  """

  @doc """
  Create a query for localizing an entity from database.

  ## Example
    To run this, you need to compose your query with the localize function.

      iex> query = from b in Blog
      iex> query = localize(query)
      iex> Repo.all(query)

    You can create your own functions for composing queries.

      defmodule MyApp.Blog do
        import TranslaTable.Query
        alias MyApp.BlogTranslation

        def run(filters \\ %{}) do
          base_query()
          |> localize_query(filters["lang"], BlogTranslation)
          |> filter_by_title(filters)
        end

        def base_query() do
          from b in Blog
        end

        def filter_by_title(query, %{title: title}) do
          from b in query,
          where: title == ^title
        end

        def filter_by_title(query, _), do: query
      end


  """
  def localize_query(query, locale_id, translation_module) do
    quote bind_quoted: [query: query, locale_id: locale_id, translation_module: translation_module] do
      fields = translation_module.__trans_schema__(:fields)
      foreign_id = translation_module.__trans_schema__(:table_foreign_id)
      from q in query,
      left_join: tm in translation_module, on: q.id == tm[foreign_id] and tm.language_id == ^locale_id,
      select_merge:  map(tm, ^fields)
    end
  end
end

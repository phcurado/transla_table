defmodule TranslaTable do
  @moduledoc """
  `TranslaTable` is a helper library for creating a translation schema inside your ecto schema.

  ## Translation

    Inside your `config.exs` add your locale config

      config :transla_table, :config, locale_schema: MyApp.Locale

    To define a translation schema it just need to use the `TranslaTable` helper inside your schema to be translated
      defmodule MyApp.Post do
        use Ecto.Schema
        use TranslaTable.Schema,
          translation_schema: MyApp.PostTranslation

        import Ecto.Changeset

        alias MyApp.PostTranslation

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

    Then create the translation module

      defmodule MyApp.PostTranslation
        use TranslaTable,
          schema: MyApp.Post,
          fields: [:title, :description, :slug]
      end

    Then the TranslaTable Macro will create a schema with the given fields and make the relation with your `Locale` schema.
  """

  defmacro __using__(opts) do
    prepare =
      quote bind_quoted: [opts: opts] do
        {{schema, pk_type}, table, fields, {locale_schema, pk_lang_type}} =
          TranslaTable.Schema.Ecto.compile_args(opts)

        @schema schema
        @pk_type pk_type
        @table table
        @fields fields
        @locale_schema locale_schema
        @pk_lang_type pk_lang_type
        @table_foreign_id (Atom.to_string(@table) <> "_id") |> String.to_existing_atom()

        def __trans_schema__(:fields), do: @fields |> Enum.map(fn {field, _type} -> field end)
        def __trans_schema__(:table), do: @table
        def __trans_schema__(:table_foreign_id), do: @table_foreign_id
      end

    contents =
      quote do
        use Ecto.Schema
        import Ecto.Changeset

        @primary_key {:id, @pk_type, autogenerate: true}
        @foreign_key_type @pk_type
        schema "#{@table}_translation" do
          belongs_to @table, @schema
          belongs_to :locale, @locale_schema, type: @pk_lang_type

          Enum.each(@fields, fn {f, t} ->
            field f, t
          end)

          timestamps()
        end

        @foreign_keys ~w"#{@table}_id locale_id"a

        @doc false
        def changeset(translation, attrs) do
          translation
          |> cast(
            attrs,
            Enum.map(@fields, fn {f, _t} -> f end) ++ @foreign_keys
          )
          |> unique_constraint(@foreign_keys)
        end
      end

    quote do
      unquote(prepare)
      unquote(contents)
    end
  end
end

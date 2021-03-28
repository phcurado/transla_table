defmodule TranslaTable do
  @moduledoc """
  `TranslaTable` is a helper library for creating a translation schema inside your ecto schema.

  ## Translation
    To define a translation schema it just need to use the `TranslaTable` helper inside your schema to be translated
      defmodule MyApp.Post do
        use Ecto.Schema
        use TranslaTable.Schema,
          translation_mod: MyApp.PostTranslation

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
        alias MyApp.Post
        alias MyApp.Language

        use TranslaTable,
          module: Post, # Module to be translated
          lang_mod: Language, # Language schema table
          fields: [:title, :description, :slug]
      end

    Then the TranslaTable Macro will create a schema with the given fields and make the relation with your `Language` module.
  """

  defmacro __using__(opts) do
    prepare =
      quote bind_quoted: [opts: opts] do
        {{module, pk_type}, table, fields, {lang_mod, pk_lang_type}} = TranslaTable.Schema.Ecto.compile_args(opts)
        @module module
        @pk_type pk_type
        @table table
        @fields fields
        @lang_mod lang_mod
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

        @primary_key false
        @foreign_key_type @pk_type
        schema "#{@table}_translation" do
          belongs_to @table, @module, primary_key: true
          belongs_to :language, @lang_mod, type: @pk_lang_type, primary_key: true

          Enum.each(@fields, fn {f, t} ->
            field f, t
          end)

          timestamps()
        end

        @doc false
        def changeset(translation, attrs) do
          translation
          |> cast(attrs, Enum.map(@fields, fn {f, _t} -> f end) ++  [:"#{@table}_id", :language_id])
        end
      end

    quote do
      unquote(prepare)
      unquote(contents)
    end
  end

  defmacro cast_translation(changeset, mod) do
    quote bind_quoted: [changeset: changeset, mod: mod] do
      cast_assoc(changeset, :translations, with: &mod.changeset/2)
    end
  end

  defmacro has_many_translations(mod) do
    quote bind_quoted: [mod: mod] do
      has_many :translations, mod, on_replace: :delete
    end
  end
end

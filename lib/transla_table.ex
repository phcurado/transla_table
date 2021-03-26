defmodule TranslaTable do
  @moduledoc """
  Documentation for `TranslaTable`.

  `TranslaTable` is a helper library for creating a translation schema inside your ecto schema.

  ## Translation
    To define a translation schema it just need to use the `TranslaTable` helper inside your schema to be translated
      defmodule MyApp.Post do
        use Ecto.Schema
        import Ecto.Changeset
        import TranslaTable

        alias MyApp.PostTranslation

        schema "post" do
          field :title, :string
          field :description, :string
          field :author, :string
          field :slug, :string

          has_many_translations PostTranslation

          timestamps()
        end

        @doc false
        def changeset(post, attrs) do
          post
          |> cast(attrs, [:title, :description, :author, :slug])
          |> cast_translation(PostTranslation)
        end
      end

      defmodule MyApp.PostTranslation
        use TranslaTable,
          module: MyApp.Blog, # Module to be translated
          lang_mod: MyApp.Language, # Language schema table
          fields: [:title, :description, :slug]
      end

    Then the TranslaTable Macro will create a schema with the given fields and make the relation with your `Language` module.
  """

  defmacro __using__(opts) do
    prepare =
      quote bind_quoted: [opts: opts] do
        {module, table, fields, {_id, pk_type}, lang_mod} = TranslaTable.Schema.compile_args(opts)
        @module module
        @table table
        @fields fields
        @pk_type pk_type
        @lang_mod lang_mod
      end

    contents =
      quote do
        use Ecto.Schema
        import Ecto.Changeset

        @primary_key false
        @foreign_key_type @pk_type
        schema "#{@table}_translation" do
          belongs_to String.to_atom(@table), @module, primary_key: true
          belongs_to :language, @lang_mod, type: :string, primary_key: true

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

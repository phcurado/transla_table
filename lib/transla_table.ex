defmodule TranslaTable do
  @moduledoc """
  Documentation for `TranslaTable`.

  `TranslaTable` is a helper library for creating a translation schema inside your ecto schema.

  ## Translation
    To define a translation schema it just need to use the `TranslaTable` helper inside your schema to be translated
      defmodule MyApp.Post do
        use Ecto.Schema
        import Ecto.Changeset

        use TranslaTable,
          module: __MODULE__,
          table_ref: :post,
          language_schema: MyApp.Language,
          fields: [{:name, :string}]
      end
  then this will create a Translation module with the relations and fields
  """

  defmacro __using__(module: module,
    table_ref: table_ref,
    language_schema: language_schema,
    fields: fields) do

      contents =
        quote do
          use Ecto.Schema

          @primary_key false
          @foreign_key_type :binary_id
          schema "#{unquote(table_ref)}_translation" do
            belongs_to unquote(table_ref), unquote(module), primary_key: true
            belongs_to :language, unquote(language_schema), type: :string, primary_key: true

            Enum.each(unquote(fields), fn {f, t} ->
              field f, t
            end)

            timestamps()
          end
        end

      changeset =
        quote do
          @doc false
          def changeset(translation, attrs) do
            translation
            |> cast(attrs, Enum.map(unquote(fields), fn {f, _t} -> f end) ++  [:"#{unquote(table_ref)}_id", :language_id])
          end
        end

    quote do
      alias unquote(:"#{__MODULE__}Translation")
      defmodule Translation do
        @moduledoc """
        Translation Schema
        """
        unquote(contents)
        unquote(changeset)
      end
    end
  end
end

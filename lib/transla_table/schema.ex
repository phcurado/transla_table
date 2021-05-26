defmodule TranslaTable.Schema do
  @moduledoc """
  `TranslaTable.Schema` will help casting translation module into your schema.

  ## Examples
    You can define your schema module with the `TranslaTable.Schema` macro to cast and define the has many association:
      defmodule MyApp.Post do

      use Ecto.Schema
      use TranslaTable.Schema,
        translation_schema: MyApp.PostTranslation

      import Ecto.Changeset

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
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      import TranslaTable.Schema

      @trans_module Keyword.fetch!(opts, :translation_schema)

      def __trans_schema__(:module), do: @trans_module
    end
  end

  defmacro cast_translation(changeset) do
    quote bind_quoted: [changeset: changeset] do
      cast_assoc(changeset, :translations, with: &@trans_module.changeset/2)
    end
  end

  defmacro has_many_translations() do
    quote do
      has_many :translations, @trans_module, on_replace: :delete
    end
  end
end

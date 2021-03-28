# TranslaTable


TranslaTable is a thin wrapper around [Ecto](https://hexdocs.pm/ecto/Ecto.html) library to provide internationalizable entities and a way to query localized data.
See the documentation on [HexDocs](https://hexdocs.pm/transla_table).

## Installation

Add the `TranslaTable` package in your `mix.exs`:

```elixir
def deps do
  [
    {:transla_table, "~> 0.2.1"}
  ]
end
```

## Language Schema
You need to create a `Language` table and schema to be used and define the languages available for translation.

### Creating language migration and schema

```elixir
defmodule MyApp.CreateLanguage do
  use Ecto.Migration

  def change do
    create table(:language, primary_key: false) do
      add :id, :string, size: 10, primary_key: true # added as string just to reference the primary key as "en", "es", "pt", etc
      add :name, :string, null: false
      timestamps()
    end
  end
end

```

```elixir
defmodule MyApp.Language do
  @moduledoc """
  Language Schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  schema "language" do
    field :name, :string
    timestamps()
  end
end
```
### Creating migration for the entity to be translated

For example, if you have a `Post` table and want it to be internationalized, create the table which will make the relation between `post` and `language`:


```elixir
defmodule MyApp.CreatePostTranslation do
  use Ecto.Migration

  def change do
    create table(:post_translation, primary_key: false) do
      # Creating post_id and language_id as primary keys
      add :post_id, references(:post, on_delete: :delete_all), primary_key: true
      add :language_id, references(:language, type: :string, on_delete: :delete_all), primary_key: true

      # fields to translate in the Post table
      add :title, :string
      add :description, :string
      add :slug, :string

      timestamps()
    end
  end
end

```

## Translate Schemas
Then in your `Post` module you define the translation methods using the `TranslaTable` helper inside your schema to be translated

```elixir
defmodule MyApp.Post do
  use Ecto.Schema
  use TranslaTable.Schema,
    translation_mod: MyApp.PostTranslation

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
```

Finally create the translation module which will automatically map the fields within the `Post` schema

```elixir
defmodule MyApp.PostTranslation
  alias MyApp.Post
  alias MyApp.Language

  use TranslaTable,
    module: Post, # Module to be translated
    lang_mod: Language, # Language schema table
    fields: [:title, :description, :slug]
end
```
then this will create a Translation module with the relations and fields.

## License
Copyright 2021 Paulo Henrique de Oliveira Curado

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
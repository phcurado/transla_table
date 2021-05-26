# TranslaTable
- [TranslaTable](#translatable)
  - [Installation](#installation)
  - [Locale Schema](#locale-schema)
    - [Creating locale migration and schema](#creating-locale-migration-and-schema)
    - [Creating migration for the entity to be translated](#creating-migration-for-the-entity-to-be-translated)
  - [Translate Schemas](#translate-schemas)
  - [Querying data](#querying-data)
  - [License](#license)

TranslaTable is a thin wrapper around [Ecto](https://hexdocs.pm/ecto/Ecto.html) library to provide internationalizable entities and a way to query localized data.
See the documentation on [HexDocs](https://hexdocs.pm/transla_table).

## Installation

Add the `TranslaTable` package in your `mix.exs`:

```elixir
def deps do
  [
    {:transla_table, "~> 0.3"}
  ]
end
```

## Locale Schema
You need to create a `Locale` table and schema to be used and define the locales available for translation.

### Creating locale migration and schema

```elixir
defmodule MyApp.CreateLocale do
  use Ecto.Migration

  def change do
    create table(:locale, primary_key: false) do
      add :id, :string, size: 10, primary_key: true # added as string just to reference the primary key as "en", "es", "pt", etc
      add :name, :string, null: false
      timestamps()
    end
  end
end

```

```elixir
defmodule MyApp.Locale do
  @moduledoc """
  Locale Schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  schema "locale" do
    field :name, :string
    timestamps()
  end
end
```

Then Inside your `config.exs` add your locale config

```Elixir

config :transla_table, :config, locale_schema: MyApp.Locale

```
### Creating migration for the entity to be translated

For example, if you have a `Post` table and want it to be internationalized, create the table which will make the relation between `post` and `locale`:


```elixir
defmodule MyApp.CreatePostTranslation do
  use Ecto.Migration

  def change do
    create table(:post_translation) do
      add :post_id, references(:post, on_delete: :delete_all)
      add :locale_id, references(:locale, type: :string, on_delete: :delete_all)

      # fields to translate in the Post table
      add :title, :string
      add :description, :string
      add :slug, :string

      timestamps()
    end
    create unique_index(:post_translation, [:post_id, :locale_id])
  end
end

```

## Translate Schemas
Then in your `Post` module you define the translation methods using the `TranslaTable` helper inside your schema to be translated

```elixir
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
```

Finally create the translation module which will automatically map the fields within the `Post` schema

```elixir
defmodule MyApp.PostTranslation
  use TranslaTable,
    schema: MyApp.Post,
    fields: [:title, :description, :slug]
end
```
then this will create a Translation module with the relations and fields.

## Querying data

Using the same example above, it is possible to query data to return only localized fields.

```Elixir
defmodule MyApp.PostContext do
  import Ecto.Query
  import TranslaTable.Query
  
  alias MyApp.Post
  alias MyApp.Repo

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

...
## then you can list the posts with translations
iex> MyApp.PostContext.list_all()
[
  %MyApp.Post{
    description: "Description",
    title: "Blog Post",
    translations: [
      %MyApp.PostTranslation{
        description: "Description",
        title: "Blog Post"
      },
      %MyApp.PostTranslation{
        description: "Descrição",
        title: "Post do Blog"
      }
    ]
  }
]

# also you can define which locale you want to return
iex> MyApp.PostContext.list_localized("pt")
[
  %MyApp.Post{
    description: "Descrição",
    title: "Post do Blog"
  }
]
```


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
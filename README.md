# TranslaTable

Ecto based project for create translation schema and query data.
See the documentation on [HexDocs](https://hexdocs.pm/transla_table)

## Installation

Add the `TranslaTable` package in your `mix.exs`:

```elixir
def deps do
  [
    {:transla_table, "~> 0.2.0"}
  ]
end
```

## Language Schema
You need to create a `Language` table and schema to be used and define the languages available for translation.

### Creating table migration
```elixir
defmodule MyApp.CreateLanguage do
  use Ecto.Migration

  def change do
    create table(:language, primary_key: false) do
      add :id, :string, size: 10, primary_key: true
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

## Translate Schemas
To define a translation schema it just need to use the `TranslaTable` helper inside your schema to be translated

```elixir
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
```

Then create the translation module

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
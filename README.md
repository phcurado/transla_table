# TranslaTable

## Installation

Add the `TranslaTable` package in your `mix.exs`:

```elixir
def deps do
  [
    {:transla_table, git:  "https://github.com/phcurado/transla_table"}
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

  use TranslaTable,
    module: __MODULE__,
    table_ref: :post,
    language_schema: MyApp.Language,
    fields: [{:name, :string}]
end
```
then this will create a Translation module with the relations and fields.
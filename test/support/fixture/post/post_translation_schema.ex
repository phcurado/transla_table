defmodule TranslaTable.Fixture.Schema.PostTranslation do
  @moduledoc false

  use TranslaTable,
    schema: TranslaTable.Fixture.Schema.Post,
    fields: [:title, :description, :slug]
end

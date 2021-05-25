defmodule TranslaTable.Fixture.Schema.PostTranslation do
  @moduledoc false

  use TranslaTable,
    module: TranslaTable.Fixture.Schema.Post,
    fields: [:title, :description, :slug]
end

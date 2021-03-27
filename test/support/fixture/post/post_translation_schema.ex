defmodule TranslaTable.Fixture.Schema.PostTranslation do
  @moduledoc false

  alias TranslaTable.Fixture.Schema.Post
  use TranslaTable,
    module: Post,
    fields: [:title, :description, :slug]
end

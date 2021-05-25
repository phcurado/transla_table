defmodule TranslaTable.Fixture.Post do
  @moduledoc false

  alias TranslaTable.Fixture.Schema.Post
  alias TranslaTable.Repo

  def insert(attrs) when is_map(attrs) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert!()
  end

  def seed() do
    post =
      insert(%{
        title: "Blog Post",
        description: "Description"
      })

    %{post: post}
  end

  def seed_with_lang(en_id, pt_id) do
    post =
      insert(%{
        title: "Blog Post",
        description: "Description",
        translations: [
          %{
            language_id: en_id,
            title: "Blog Post",
            description: "Description"
          },
          %{
            language_id: pt_id,
            title: "Post do Blog",
            description: "Descrição"
          }
        ]
      })

    %{post: post}
  end
end

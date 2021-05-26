defmodule TranslaTable.Repo.Migrations.CreatePostTranslationTable do
  use Ecto.Migration

  def change do
    create table("post_translation") do
      add :post_id, references(:post, on_delete: :delete_all)
      add :locale_id, references(:language, on_delete: :delete_all)
      add :title, :string, size: 40
      add :description, :string, size: 255
      add :slug, :string, size: 20

      timestamps()
    end
    create unique_index(:post_translation, [:post_id, :locale_id])
  end
end

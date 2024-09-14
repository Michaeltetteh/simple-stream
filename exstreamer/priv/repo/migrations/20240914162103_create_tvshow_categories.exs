defmodule Exstreamer.Repo.Migrations.CreateTvshowCategories do
  use Ecto.Migration

def change do
    create table(:tvshow_categories, primary_key: false) do
      add :tvshow_id, references(:tvshows, on_delete: :delete_all)
      add :category_id, references(:categories, on_delete: :delete_all)
    end

    create index(:tvshow_categories, [:tvshow_id])
    create unique_index(:tvshow_categories, [:tvshow_id, :category_id])
  end
end

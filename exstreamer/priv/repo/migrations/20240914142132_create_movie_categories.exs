defmodule Exstreamer.Repo.Migrations.CreateMovieCategories do
  use Ecto.Migration

  def change do
    create table(:movie_categories, primary_key: false) do
      add :movie_id, references(:movies, on_delete: :delete_all)
      add :category_id, references(:categories, on_delete: :delete_all)
    end

    create index(:movie_categories, [:movie_id])
    create unique_index(:movie_categories, [:movie_id, :category_id])
  end
end

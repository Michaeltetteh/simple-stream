defmodule Exstreamer.Repo.Migrations.CreateTvSeries do
  use Ecto.Migration

  def change do
    create table(:tv_series) do
      add :title, :string, null: false
      add :description, :string
      add :rating, :decimal
      add :poster, :string

      add :uploaded_by, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:tv_series, [:title])

    create table(:tv_series_categories, primary_key: false) do
      add :tv_series_id, references(:tv_series, on_delete: :delete_all)
      add :category_id, references(:categories, on_delete: :delete_all)
    end

    create index(:tv_series_categories, [:tv_series_id])
    create unique_index(:tv_series_categories, [:tv_series_id, :category_id])
  end
end

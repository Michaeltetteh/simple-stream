defmodule Exstreamer.Repo.Migrations.CreateCatalogs do
  use Ecto.Migration

  def change do
    create table(:catalogs) do
      add :title, :string
      add :categories, :string
      add :rating, :decimal
      add :description, :string
      add :is_tv_show, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end

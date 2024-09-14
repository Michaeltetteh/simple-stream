defmodule Exstreamer.Repo.Migrations.CreateFiles do
  use Ecto.Migration

  def change do
    create table(:files) do
      add :name, :string
      add :path, :string
      add :size, :integer
      add :type, :string

      timestamps(type: :utc_datetime)
    end
  end
end

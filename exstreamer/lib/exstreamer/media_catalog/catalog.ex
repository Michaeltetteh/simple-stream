defmodule Exstreamer.MediaCatalog.Catalog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "catalogs" do
    field :description, :string
    field :title, :string
    field :categories, :string
    field :rating, :decimal
    field :is_tv_show, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(catalog, attrs) do
    catalog
    |> cast(attrs, [:title, :categories, :rating, :description, :is_tv_show])
    |> validate_required([:title, :categories, :rating, :description, :is_tv_show])
  end
end

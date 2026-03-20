defmodule Exstreamer.MediaCatalog.TVSeries do
  use Ecto.Schema
  import Ecto.Changeset
  alias Exstreamer.MediaCatalog.Category

  schema "tv_series" do
    field :title, :string
    field :description, :string
    field :rating, :decimal
    field :poster, :string

    many_to_many :categories, Category, join_through: "tv_series_categories", on_replace: :delete
    belongs_to :uploader, Exstreamer.Accounts.User, foreign_key: :uploaded_by
    has_many :seasons, Exstreamer.MediaCatalog.TVShow, foreign_key: :tv_series_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tv_series, attrs) do
    tv_series
    |> cast(attrs, [:title, :description, :rating, :poster, :uploaded_by])
    |> validate_required([:title])
    |> unique_constraint(:title)
  end
end

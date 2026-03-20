defmodule Exstreamer.MediaCatalog.TVShow do
  use Ecto.Schema
  import Ecto.Changeset
  alias Exstreamer.MediaCatalog.Category

  schema "tvshows" do
    field :description, :string
    field :title, :string
    field :rating, :decimal
    field :poster, :string
    field :season_no, :integer, default: 1

    many_to_many :categories, Category, join_through: "tvshow_categories", on_replace: :delete
    belongs_to :uploader, Exstreamer.Accounts.User, foreign_key: :uploaded_by
    belongs_to :tv_series, Exstreamer.MediaCatalog.TVSeries

    has_many :episodes, Exstreamer.MediaCatalog.Episode, foreign_key: :tvshow_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tv_show, attrs) do
    tv_show
    |> cast(attrs, [:title, :rating, :description, :poster, :season_no, :tv_series_id, :uploaded_by])
    |> validate_required([:title])
  end
end


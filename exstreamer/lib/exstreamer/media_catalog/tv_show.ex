defmodule Exstreamer.MediaCatalog.TVShow do
  use Ecto.Schema
  import Ecto.Changeset
  alias Exstreamer.MediaCatalog.Category

  schema "tvshows" do
    field :description, :string
    field :title, :string
    field :rating, :decimal
    field :poster, :string

    many_to_many :categories, Category, join_through: "movie_categories", on_replace: :delete
    belongs_to :uploaded_by, Exstreamer.Accounts.User
    
    has_many :episodes, Exstreamer.MediaCatalog.Episode

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tv_show, attrs) do
    tv_show
    |> cast(attrs, [:title, :categories, :rating, :description, :poster])
    |> validate_required([:title, :categories, :rating, :description, :poster])
  end
end


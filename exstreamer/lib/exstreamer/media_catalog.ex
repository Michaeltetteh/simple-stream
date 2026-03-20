defmodule Exstreamer.MediaCatalog do
  @moduledoc """
  The MediaCatalog context — manages Movies, TV Series, Seasons, Episodes,
  Files, and Categories.
  """

  import Ecto.Query, warn: false
  alias Exstreamer.Repo

  alias Exstreamer.MediaCatalog.{Movie, MediaFile, TVSeries, TVShow, Episode, Category}

  # ---------------------------------------------------------------------------
  # Movies
  # ---------------------------------------------------------------------------

  def list_movies do
    Movie
    |> order_by([m], desc: m.inserted_at)
    |> Repo.all()
    |> Repo.preload([:categories, :file])
  end

  def list_movies_by_category(category_id) do
    Movie
    |> join(:inner, [m], c in assoc(m, :categories), on: c.id == ^category_id)
    |> order_by([m], desc: m.inserted_at)
    |> Repo.all()
    |> Repo.preload([:categories, :file])
  end

  def search_movies(query) do
    term = "%#{query}%"

    Movie
    |> where([m], ilike(m.title, ^term) or ilike(m.description, ^term))
    |> order_by([m], asc: m.title)
    |> Repo.all()
    |> Repo.preload([:categories, :file])
  end

  def get_movie!(id) do
    Movie
    |> Repo.get!(id)
    |> Repo.preload([:categories, :file])
  end

  def create_movie(attrs \\ %{}) do
    %Movie{}
    |> Movie.changeset(attrs)
    |> Repo.insert()
  end

  def create_movie_with_categories(attrs, category_ids) do
    categories = Repo.all(from c in Category, where: c.id in ^category_ids)

    %Movie{}
    |> Movie.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:categories, categories)
    |> Repo.insert()
  end

  def update_movie(%Movie{} = movie, attrs) do
    movie
    |> Movie.changeset(attrs)
    |> Repo.update()
  end

  def update_movie_with_categories(%Movie{} = movie, attrs, category_ids) do
    categories = Repo.all(from c in Category, where: c.id in ^category_ids)
    movie = Repo.preload(movie, :categories)

    movie
    |> Movie.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:categories, categories)
    |> Repo.update()
  end

  def delete_movie(%Movie{} = movie), do: Repo.delete(movie)

  def change_movie(%Movie{} = movie, attrs \\ %{}) do
    Movie.changeset(movie, attrs)
  end

  # ---------------------------------------------------------------------------
  # TV Series (parent show grouping seasons)
  # ---------------------------------------------------------------------------

  def list_tv_series do
    TVSeries
    |> order_by([s], desc: s.inserted_at)
    |> Repo.all()
    |> Repo.preload([:categories, :seasons])
  end

  def search_tv_series(query) do
    term = "%#{query}%"

    TVSeries
    |> where([s], ilike(s.title, ^term) or ilike(s.description, ^term))
    |> order_by([s], asc: s.title)
    |> Repo.all()
    |> Repo.preload([:categories])
  end

  def get_tv_series!(id) do
    TVSeries
    |> Repo.get!(id)
    |> Repo.preload([:categories, seasons: {from(s in TVShow, order_by: s.season_no), [episodes: {from(e in Episode, order_by: e.number), :file}]}])
  end

  def create_tv_series(attrs \\ %{}) do
    %TVSeries{}
    |> TVSeries.changeset(attrs)
    |> Repo.insert()
  end

  def create_tv_series_with_categories(attrs, category_ids) do
    categories = Repo.all(from c in Category, where: c.id in ^category_ids)

    %TVSeries{}
    |> TVSeries.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:categories, categories)
    |> Repo.insert()
  end

  def update_tv_series(%TVSeries{} = series, attrs) do
    series
    |> TVSeries.changeset(attrs)
    |> Repo.update()
  end

  def update_tv_series_with_categories(%TVSeries{} = series, attrs, category_ids) do
    categories = Repo.all(from c in Category, where: c.id in ^category_ids)
    series = Repo.preload(series, :categories)

    series
    |> TVSeries.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:categories, categories)
    |> Repo.update()
  end

  def delete_tv_series(%TVSeries{} = series), do: Repo.delete(series)

  def change_tv_series(%TVSeries{} = series, attrs \\ %{}) do
    TVSeries.changeset(series, attrs)
  end

  # ---------------------------------------------------------------------------
  # TV Shows (seasons)
  # ---------------------------------------------------------------------------

  def list_tvshows do
    Repo.all(TVShow) |> Repo.preload([:categories, :episodes])
  end

  def list_seasons_for_series(tv_series_id) do
    TVShow
    |> where([s], s.tv_series_id == ^tv_series_id)
    |> order_by([s], asc: s.season_no)
    |> Repo.all()
    |> Repo.preload(episodes: from(e in Episode, order_by: e.number))
  end

  def get_tv_show!(id) do
    TVShow
    |> Repo.get!(id)
    |> Repo.preload([
      :categories,
      :tv_series,
      episodes: {from(e in Episode, order_by: e.number), :file}
    ])
  end

  def create_tv_show(attrs \\ %{}) do
    %TVShow{}
    |> TVShow.changeset(attrs)
    |> Repo.insert()
  end

  def update_tv_show(%TVShow{} = tv_show, attrs) do
    tv_show
    |> TVShow.changeset(attrs)
    |> Repo.update()
  end

  def delete_tv_show(%TVShow{} = tv_show), do: Repo.delete(tv_show)

  def change_tv_show(%TVShow{} = tv_show, attrs \\ %{}) do
    TVShow.changeset(tv_show, attrs)
  end

  # ---------------------------------------------------------------------------
  # Episodes
  # ---------------------------------------------------------------------------

  def list_episodes_for_season(tvshow_id) do
    Episode
    |> where([e], e.tvshow_id == ^tvshow_id)
    |> order_by([e], asc: e.number)
    |> Repo.all()
    |> Repo.preload(:file)
  end

  def get_episode!(id) do
    Episode
    |> Repo.get!(id)
    |> Repo.preload([:file, tvshow: :tv_series])
  end

  def create_episode(attrs \\ %{}) do
    %Episode{}
    |> Episode.changeset(attrs)
    |> Repo.insert()
  end

  def update_episode(%Episode{} = episode, attrs) do
    episode
    |> Episode.changeset(attrs)
    |> Repo.update()
  end

  def delete_episode(%Episode{} = episode), do: Repo.delete(episode)

  def change_episode(%Episode{} = episode, attrs \\ %{}) do
    Episode.changeset(episode, attrs)
  end

  # ---------------------------------------------------------------------------
  # Media Files
  # ---------------------------------------------------------------------------

  def count_episodes, do: Repo.aggregate(Episode, :count)

  def list_files, do: Repo.all(MediaFile)

  def get_media_file!(id), do: Repo.get!(MediaFile, id)

  def create_media_file(attrs \\ %{}) do
    %MediaFile{}
    |> MediaFile.changeset(attrs)
    |> Repo.insert()
  end

  def update_media_file(%MediaFile{} = media_file, attrs) do
    media_file
    |> MediaFile.changeset(attrs)
    |> Repo.update()
  end

  def delete_media_file(%MediaFile{} = media_file), do: Repo.delete(media_file)

  def change_media_file(%MediaFile{} = media_file, attrs \\ %{}) do
    MediaFile.changeset(media_file, attrs)
  end
end

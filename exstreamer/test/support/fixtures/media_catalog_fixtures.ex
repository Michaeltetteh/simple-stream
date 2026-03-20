defmodule Exstreamer.MediaCatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Exstreamer.MediaCatalog` context.
  """

  @doc """
  Generate a movie.
  """
  def movie_fixture(attrs \\ %{}) do
    {:ok, movie} =
      attrs
      |> Enum.into(%{
        title: "some movie #{System.unique_integer([:positive])}",
        description: "some description",
        rating: "7.5",
        poster: "/posters/default.jpg"
      })
      |> Exstreamer.MediaCatalog.create_movie()

    movie
  end

  @doc """
  Generate a tv_series.
  """
  def tv_series_fixture(attrs \\ %{}) do
    {:ok, series} =
      attrs
      |> Enum.into(%{
        title: "some series #{System.unique_integer([:positive])}",
        description: "some description",
        rating: "8.0"
      })
      |> Exstreamer.MediaCatalog.create_tv_series()

    series
  end

  @doc """
  Generate a media_file.
  """
  def media_file_fixture(attrs \\ %{}) do
    {:ok, media_file} =
      attrs
      |> Enum.into(%{
        name: "some name",
        path: "some path",
        size: 42,
        type: "some type"
      })
      |> Exstreamer.MediaCatalog.create_media_file()

    media_file
  end

  @doc """
  Generate a tv_show (season).
  """
  def tv_show_fixture(attrs \\ %{}) do
    {:ok, tv_show} =
      attrs
      |> Enum.into(%{
        title: "Season #{System.unique_integer([:positive])}",
        description: "Season description",
        poster: "/posters/season.jpg",
        season_no: 1
      })
      |> Exstreamer.MediaCatalog.create_tv_show()

    tv_show
  end

  @doc """
  Generate an episode.
  """
  def episode_fixture(attrs \\ %{}) do
    tv_show = tv_show_fixture()

    {:ok, episode} =
      attrs
      |> Enum.into(%{
        title: "some episode",
        number: 1,
        tvshow_id: tv_show.id
      })
      |> Exstreamer.MediaCatalog.create_episode()

    episode
  end
end

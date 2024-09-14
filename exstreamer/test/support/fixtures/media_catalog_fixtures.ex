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

      })
      |> Exstreamer.MediaCatalog.create_movie()

    movie
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
  Generate a tv_show.
  """
  def tv_show_fixture(attrs \\ %{}) do
    {:ok, tv_show} =
      attrs
      |> Enum.into(%{

      })
      |> Exstreamer.MediaCatalog.create_tv_show()

    tv_show
  end
end

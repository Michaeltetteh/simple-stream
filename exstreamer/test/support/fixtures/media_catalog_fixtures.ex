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
end

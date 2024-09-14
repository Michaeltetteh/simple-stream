defmodule Exstreamer.MediaCatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Exstreamer.MediaCatalog` context.
  """

  @doc """
  Generate a catalog.
  """
  def catalog_fixture(attrs \\ %{}) do
    {:ok, catalog} =
      attrs
      |> Enum.into(%{
        categories: "some categories",
        description: "some description",
        is_tv_show: true,
        rating: "120.5",
        title: "some title"
      })
      |> Exstreamer.MediaCatalog.create_catalog()

    catalog
  end
end

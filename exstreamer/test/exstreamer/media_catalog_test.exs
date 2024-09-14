defmodule Exstreamer.MediaCatalogTest do
  use Exstreamer.DataCase

  alias Exstreamer.MediaCatalog

  describe "catalogs" do
    alias Exstreamer.MediaCatalog.Catalog

    import Exstreamer.MediaCatalogFixtures

    @invalid_attrs %{description: nil, title: nil, categories: nil, rating: nil, is_tv_show: nil}

    test "list_catalogs/0 returns all catalogs" do
      catalog = catalog_fixture()
      assert MediaCatalog.list_catalogs() == [catalog]
    end

    test "get_catalog!/1 returns the catalog with given id" do
      catalog = catalog_fixture()
      assert MediaCatalog.get_catalog!(catalog.id) == catalog
    end

    test "create_catalog/1 with valid data creates a catalog" do
      valid_attrs = %{description: "some description", title: "some title", categories: "some categories", rating: "120.5", is_tv_show: true}

      assert {:ok, %Catalog{} = catalog} = MediaCatalog.create_catalog(valid_attrs)
      assert catalog.description == "some description"
      assert catalog.title == "some title"
      assert catalog.categories == "some categories"
      assert catalog.rating == Decimal.new("120.5")
      assert catalog.is_tv_show == true
    end

    test "create_catalog/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = MediaCatalog.create_catalog(@invalid_attrs)
    end

    test "update_catalog/2 with valid data updates the catalog" do
      catalog = catalog_fixture()
      update_attrs = %{description: "some updated description", title: "some updated title", categories: "some updated categories", rating: "456.7", is_tv_show: false}

      assert {:ok, %Catalog{} = catalog} = MediaCatalog.update_catalog(catalog, update_attrs)
      assert catalog.description == "some updated description"
      assert catalog.title == "some updated title"
      assert catalog.categories == "some updated categories"
      assert catalog.rating == Decimal.new("456.7")
      assert catalog.is_tv_show == false
    end

    test "update_catalog/2 with invalid data returns error changeset" do
      catalog = catalog_fixture()
      assert {:error, %Ecto.Changeset{}} = MediaCatalog.update_catalog(catalog, @invalid_attrs)
      assert catalog == MediaCatalog.get_catalog!(catalog.id)
    end

    test "delete_catalog/1 deletes the catalog" do
      catalog = catalog_fixture()
      assert {:ok, %Catalog{}} = MediaCatalog.delete_catalog(catalog)
      assert_raise Ecto.NoResultsError, fn -> MediaCatalog.get_catalog!(catalog.id) end
    end

    test "change_catalog/1 returns a catalog changeset" do
      catalog = catalog_fixture()
      assert %Ecto.Changeset{} = MediaCatalog.change_catalog(catalog)
    end
  end
end

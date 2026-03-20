defmodule Exstreamer.CategoriesTest do
  use Exstreamer.DataCase

  alias Exstreamer.Category

  describe "categories" do
    alias Exstreamer.MediaCatalog.Category, as: CategorySchema

    import Exstreamer.CategoriesFixtures

    @invalid_attrs %{name: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert category in Category.list_categories()
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Category.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %CategorySchema{} = category} = Category.create_category(valid_attrs)
      assert category.name == "some name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Category.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %CategorySchema{} = category} = Category.update_category(category, update_attrs)
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Category.update_category(category, @invalid_attrs)
      assert category == Category.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %CategorySchema{}} = Category.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Category.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Category.change_category(category)
    end
  end
end

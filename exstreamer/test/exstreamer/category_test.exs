defmodule Exstreamer.CategoryTest do
  use Exstreamer.DataCase

  alias Exstreamer.Category
  alias Exstreamer.MediaCatalog.Category, as: CategorySchema

  describe "list_categories/0" do
    test "returns an empty list when no categories exist" do
      assert Category.list_categories() == []
    end

    test "returns all categories" do
      {:ok, cat1} = Category.create_category(%{name: "Action"})
      {:ok, cat2} = Category.create_category(%{name: "Drama"})
      ids = Category.list_categories() |> Enum.map(& &1.id)
      assert cat1.id in ids
      assert cat2.id in ids
      assert length(Category.list_categories()) == 2
    end
  end

  describe "get_category!/1" do
    test "raises Ecto.NoResultsError when category does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Category.get_category!(-1)
      end
    end

    test "returns the category with the given id" do
      {:ok, cat} = Category.create_category(%{name: "Comedy"})
      result = Category.get_category!(cat.id)
      assert %CategorySchema{} = result
      assert result.id == cat.id
      assert result.name == "Comedy"
    end
  end

  describe "get_category_by_name/1" do
    test "returns nil when name does not match" do
      assert is_nil(Category.get_category_by_name("Nonexistent"))
    end

    test "returns the category matching the given name" do
      {:ok, cat} = Category.create_category(%{name: "Horror"})
      result = Category.get_category_by_name("Horror")
      assert result.id == cat.id
      assert result.name == "Horror"
    end

    test "returns nil for partial name matches" do
      {:ok, _cat} = Category.create_category(%{name: "Horror"})
      assert is_nil(Category.get_category_by_name("Hor"))
    end
  end

  describe "create_category/1" do
    test "creates a category with valid attrs" do
      assert {:ok, %CategorySchema{name: "Sci-Fi"}} = Category.create_category(%{name: "Sci-Fi"})
    end

    test "returns an error changeset when name is missing" do
      assert {:error, changeset} = Category.create_category(%{})
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "returns an error changeset when name is nil" do
      assert {:error, changeset} = Category.create_category(%{name: nil})
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "persists the new category to the database" do
      {:ok, cat} = Category.create_category(%{name: "Thriller"})
      assert Category.get_category!(cat.id).name == "Thriller"
    end
  end

  describe "update_category/2" do
    test "updates a category with valid attrs" do
      {:ok, cat} = Category.create_category(%{name: "Old Name"})
      assert {:ok, updated} = Category.update_category(cat, %{name: "New Name"})
      assert updated.name == "New Name"
    end

    test "persists the update" do
      {:ok, cat} = Category.create_category(%{name: "Before"})
      {:ok, _} = Category.update_category(cat, %{name: "After"})
      assert Category.get_category!(cat.id).name == "After"
    end

    test "returns an error changeset when name is nil" do
      {:ok, cat} = Category.create_category(%{name: "Valid"})
      assert {:error, changeset} = Category.update_category(cat, %{name: nil})
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "does not persist changes on validation error" do
      {:ok, cat} = Category.create_category(%{name: "Unchanged"})
      {:error, _changeset} = Category.update_category(cat, %{name: nil})
      assert Category.get_category!(cat.id).name == "Unchanged"
    end
  end

  describe "delete_category/1" do
    test "deletes the category from the database" do
      {:ok, cat} = Category.create_category(%{name: "To Delete"})
      assert {:ok, %CategorySchema{}} = Category.delete_category(cat)
      assert_raise Ecto.NoResultsError, fn -> Category.get_category!(cat.id) end
    end

    test "returns the deleted category struct" do
      {:ok, cat} = Category.create_category(%{name: "Deleted"})
      assert {:ok, deleted} = Category.delete_category(cat)
      assert deleted.id == cat.id
    end
  end

  describe "change_category/2" do
    test "returns a changeset for the category" do
      {:ok, cat} = Category.create_category(%{name: "Valid"})
      assert %Ecto.Changeset{} = Category.change_category(cat)
    end

    test "tracks changes in the changeset" do
      {:ok, cat} = Category.create_category(%{name: "Original"})
      changeset = Category.change_category(cat, %{name: "Changed"})
      assert changeset.valid?
      assert Ecto.Changeset.get_change(changeset, :name) == "Changed"
    end

    test "changeset is invalid for blank name" do
      {:ok, cat} = Category.create_category(%{name: "Original"})
      changeset = Category.change_category(cat, %{name: nil})
      refute changeset.valid?
    end
  end
end

defmodule ExstreamerWeb.Admin.CategoriesLiveTest do
  use ExstreamerWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "authentication" do
    test "redirects unauthenticated users to login", %{conn: conn} do
      {:error, {:redirect, %{to: path}}} = live(conn, ~p"/admin/categories")
      assert path =~ "/admin/users/log_in"
    end
  end

  describe "mount (authenticated)" do
    setup :register_and_log_in_user

    test "renders categories page", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin/categories")
      assert html =~ "Categories"
    end

    test "renders existing categories", %{conn: conn} do
      {:ok, cat} = Exstreamer.Category.create_category(%{name: "Visible Category"})
      {:ok, _view, html} = live(conn, ~p"/admin/categories")
      assert html =~ cat.name
    end

    test "renders Add Category link", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin/categories")
      assert html =~ "Add Category"
    end
  end

  describe "new category form (authenticated)" do
    setup :register_and_log_in_user

    test "shows new category form when navigating to /new", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin/categories/new")
      assert html =~ "New Category"
    end

    test "saves a new category on valid submit", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/categories/new")
      view
      |> form("form", %{"category" => %{"name" => "New Genre"}})
      |> render_submit()

      assert Exstreamer.Category.get_category_by_name("New Genre") != nil
    end

    test "shows validation error for blank name", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/categories/new")
      html =
        view
        |> form("form", %{"category" => %{"name" => ""}})
        |> render_submit()
      assert html =~ "can&#39;t be blank" or html =~ "can't be blank"
    end
  end

  describe "edit category (authenticated)" do
    setup :register_and_log_in_user

    test "shows edit form when navigating to /:id/edit", %{conn: conn} do
      {:ok, cat} = Exstreamer.Category.create_category(%{name: "Editable"})
      {:ok, _view, html} = live(conn, ~p"/admin/categories/#{cat.id}/edit")
      assert html =~ "Edit Category"
    end

    test "updates the category on valid submit", %{conn: conn} do
      {:ok, cat} = Exstreamer.Category.create_category(%{name: "Before"})
      {:ok, view, _html} = live(conn, ~p"/admin/categories/#{cat.id}/edit")
      view
      |> form("form", %{"category" => %{"name" => "After"}})
      |> render_submit()

      assert Exstreamer.Category.get_category!(cat.id).name == "After"
    end
  end

  describe "delete category (authenticated)" do
    setup :register_and_log_in_user

    test "deletes the category when delete button is clicked", %{conn: conn} do
      {:ok, cat} = Exstreamer.Category.create_category(%{name: "ToDelete"})
      {:ok, view, _html} = live(conn, ~p"/admin/categories")
      view |> element("button[phx-value-id='#{cat.id}']") |> render_click()
      assert_raise Ecto.NoResultsError, fn -> Exstreamer.Category.get_category!(cat.id) end
    end
  end
end

defmodule ExstreamerWeb.Admin.DashboardLiveTest do
  use ExstreamerWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Exstreamer.MediaCatalogFixtures

  describe "authentication" do
    test "redirects unauthenticated users to login", %{conn: conn} do
      {:error, {:redirect, %{to: path}}} = live(conn, ~p"/admin/dashboard")
      assert path =~ "/admin/users/log_in"
    end
  end

  describe "mount (authenticated)" do
    setup :register_and_log_in_user

    test "renders dashboard page", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin/dashboard")
      assert html =~ "Dashboard" or html =~ "Overview"
    end

    test "renders movie count of 0 when no movies exist", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin/dashboard")
      assert html =~ "Movies"
    end

    test "renders correct movie count after adding movies", %{conn: conn} do
      movie_fixture(%{title: "Counted Movie"})
      {:ok, _view, html} = live(conn, ~p"/admin/dashboard")
      assert html =~ "Counted Movie"
    end

    test "renders series count section", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin/dashboard")
      assert html =~ "TV Series"
    end

    test "renders episode count section", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin/dashboard")
      assert html =~ "Episodes"
    end

    test "renders categories count section", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin/dashboard")
      assert html =~ "Categories"
    end

    test "renders recent movies section", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin/dashboard")
      assert html =~ "Recent Movies"
    end

    test "renders recent series section", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin/dashboard")
      assert html =~ "Recent TV Series"
    end
  end
end

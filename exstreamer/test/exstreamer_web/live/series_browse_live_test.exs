defmodule ExstreamerWeb.SeriesBrowseLiveTest do
  use ExstreamerWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Exstreamer.MediaCatalogFixtures

  describe "mount" do
    test "renders the series browse page", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/series")
      assert html =~ "TV Series"
    end

    test "renders all series", %{conn: conn} do
      series = tv_series_fixture(%{title: "Visible Series"})
      {:ok, _view, html} = live(conn, ~p"/series")
      assert html =~ series.title
    end

    test "renders empty state when no series exist", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/series")
      assert html =~ "No series found"
    end

    test "shows category filter badges", %{conn: conn} do
      {:ok, cat} = Exstreamer.Category.create_category(%{name: "Comedy"})
      {:ok, _view, html} = live(conn, ~p"/series")
      assert html =~ cat.name
    end
  end

  describe "handle_params - search filter" do
    test "filters series by search query", %{conn: conn} do
      tv_series_fixture(%{title: "FindMe Series"})
      tv_series_fixture(%{title: "OtherShow"})
      {:ok, _view, html} = live(conn, ~p"/series?q=FindMe")
      assert html =~ "FindMe Series"
      refute html =~ "OtherShow"
    end

    test "shows all series when search is empty", %{conn: conn} do
      s1 = tv_series_fixture(%{title: "First Show"})
      s2 = tv_series_fixture(%{title: "Second Show"})
      {:ok, _view, html} = live(conn, ~p"/series")
      assert html =~ s1.title
      assert html =~ s2.title
    end

    test "shows empty state for non-matching search", %{conn: conn} do
      tv_series_fixture(%{title: "Real Show"})
      {:ok, _view, html} = live(conn, ~p"/series?q=zzznomatch")
      assert html =~ "No series found"
    end
  end

  describe "handle_params - category filter" do
    test "filters series by category", %{conn: conn} do
      {:ok, cat} = Exstreamer.Category.create_category(%{name: "Fantasy"})
      {:ok, matched} = Exstreamer.MediaCatalog.create_tv_series_with_categories(%{title: "Fantasy Show"}, [cat.id])
      tv_series_fixture(%{title: "Other Show"})

      {:ok, _view, html} = live(conn, ~p"/series?category=#{cat.id}")
      assert html =~ matched.title
      refute html =~ "Other Show"
    end
  end
end

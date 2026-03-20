defmodule ExstreamerWeb.SeriesDetailLiveTest do
  use ExstreamerWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Exstreamer.MediaCatalogFixtures

  describe "mount" do
    test "renders series detail page", %{conn: conn} do
      series = tv_series_fixture(%{title: "Drama Series", description: "A gripping drama"})
      {:ok, _view, html} = live(conn, ~p"/series/#{series.id}")
      assert html =~ series.title
    end

    test "renders series description when present", %{conn: conn} do
      series = tv_series_fixture(%{title: "Described Show", description: "Show description text"})
      {:ok, _view, html} = live(conn, ~p"/series/#{series.id}")
      assert html =~ "Show description text"
    end

    test "renders season count information", %{conn: conn} do
      series = tv_series_fixture(%{title: "Multi Season"})
      {:ok, _view, html} = live(conn, ~p"/series/#{series.id}")
      assert html =~ "Season(s)"
    end

    test "renders category badges for series categories", %{conn: conn} do
      {:ok, cat} = Exstreamer.Category.create_category(%{name: "Drama"})
      {:ok, series} = Exstreamer.MediaCatalog.create_tv_series_with_categories(%{title: "Drama Show"}, [cat.id])
      {:ok, _view, html} = live(conn, ~p"/series/#{series.id}")
      assert html =~ "Drama"
    end

    test "raises when series does not exist", %{conn: conn} do
      assert_raise Ecto.NoResultsError, fn ->
        live(conn, ~p"/series/0")
      end
    end

    test "renders season selector when seasons exist", %{conn: conn} do
      series = tv_series_fixture(%{title: "With Seasons"})
      {:ok, _season} = Exstreamer.MediaCatalog.create_tv_show(%{
        title: "Season 1",
        description: "First season",
        poster: "/posters/s1.jpg",
        season_no: 1,
        tv_series_id: series.id
      })
      {:ok, _view, html} = live(conn, ~p"/series/#{series.id}")
      assert html =~ "Season 1"
    end
  end

  describe "handle_event select_season" do
    test "changes the active season when a season button is clicked", %{conn: conn} do
      series = tv_series_fixture(%{title: "Selectable Show"})
      {:ok, s1} = Exstreamer.MediaCatalog.create_tv_show(%{title: "Season 1", description: "d", poster: "/p.jpg", season_no: 1, tv_series_id: series.id})
      {:ok, s2} = Exstreamer.MediaCatalog.create_tv_show(%{title: "Season 2", description: "d", poster: "/p.jpg", season_no: 2, tv_series_id: series.id})

      {:ok, view, _html} = live(conn, ~p"/series/#{series.id}")
      html = view |> element("button[phx-value-id='#{s2.id}']") |> render_click()
      assert html =~ "Season 2"
      _ = s1
    end
  end
end

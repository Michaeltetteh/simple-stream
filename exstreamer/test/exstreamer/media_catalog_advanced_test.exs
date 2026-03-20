defmodule Exstreamer.MediaCatalogAdvancedTest do
  use Exstreamer.DataCase

  alias Exstreamer.MediaCatalog
  alias Exstreamer.MediaCatalog.{Movie, TVSeries, TVShow, Episode}
  alias Exstreamer.Category

  import Exstreamer.MediaCatalogFixtures

  # ---------------------------------------------------------------------------
  # Movie changeset validation
  # ---------------------------------------------------------------------------

  describe "Movie changeset" do
    test "changeset is valid with required fields" do
      changeset = Movie.changeset(%Movie{}, %{title: "Valid Movie"})
      assert changeset.valid?
    end

    test "changeset is invalid when title is missing" do
      changeset = Movie.changeset(%Movie{}, %{})
      refute changeset.valid?
      assert %{title: ["can't be blank"]} = errors_on(changeset)
    end

    test "changeset casts optional fields" do
      attrs = %{title: "Movie", description: "Desc", rating: "8.5", poster: "/path/poster.jpg"}
      changeset = Movie.changeset(%Movie{}, attrs)
      assert changeset.valid?
      assert Ecto.Changeset.get_change(changeset, :description) == "Desc"
      assert Ecto.Changeset.get_change(changeset, :poster) == "/path/poster.jpg"
    end
  end

  # ---------------------------------------------------------------------------
  # Movie search
  # ---------------------------------------------------------------------------

  describe "search_movies/1" do
    test "returns movies matching title" do
      {:ok, _} = MediaCatalog.create_movie(%{title: "The Dark Knight", description: "d", poster: "/p.jpg"})
      {:ok, _} = MediaCatalog.create_movie(%{title: "Interstellar", description: "d", poster: "/p2.jpg"})
      results = MediaCatalog.search_movies("dark")
      assert length(results) == 1
      assert hd(results).title == "The Dark Knight"
    end

    test "returns movies matching description" do
      {:ok, _} = MediaCatalog.create_movie(%{title: "Mystery Film", description: "A noir story", poster: "/p.jpg"})
      {:ok, _} = MediaCatalog.create_movie(%{title: "Comedy Film", description: "Very funny", poster: "/p2.jpg"})
      results = MediaCatalog.search_movies("noir")
      assert length(results) == 1
      assert hd(results).title == "Mystery Film"
    end

    test "returns empty list when no matches" do
      {:ok, _} = MediaCatalog.create_movie(%{title: "Inception", description: "d", poster: "/p.jpg"})
      assert MediaCatalog.search_movies("zzznomatch") == []
    end

    test "is case-insensitive" do
      {:ok, _} = MediaCatalog.create_movie(%{title: "Pulp Fiction", description: "d", poster: "/p.jpg"})
      results = MediaCatalog.search_movies("PULP")
      assert length(results) == 1
    end
  end

  # ---------------------------------------------------------------------------
  # Movie category associations
  # ---------------------------------------------------------------------------

  describe "list_movies_by_category/1" do
    test "returns movies in the given category" do
      {:ok, cat} = Category.create_category(%{name: "Action"})
      {:ok, movie} = MediaCatalog.create_movie_with_categories(%{title: "Action Movie", description: "d", poster: "/p.jpg"}, [cat.id])
      {:ok, _other} = MediaCatalog.create_movie(%{title: "No Category Movie", description: "d", poster: "/p2.jpg"})

      results = MediaCatalog.list_movies_by_category(cat.id)
      assert length(results) == 1
      assert hd(results).id == movie.id
    end

    test "returns empty list when no movies exist in category" do
      {:ok, cat} = Category.create_category(%{name: "Empty Category"})
      assert MediaCatalog.list_movies_by_category(cat.id) == []
    end
  end

  describe "create_movie_with_categories/2" do
    test "creates a movie and associates categories" do
      {:ok, cat1} = Category.create_category(%{name: "Drama"})
      {:ok, cat2} = Category.create_category(%{name: "Thriller"})
      {:ok, movie} = MediaCatalog.create_movie_with_categories(%{title: "Dual Genre", description: "d", poster: "/p.jpg"}, [cat1.id, cat2.id])

      loaded = MediaCatalog.get_movie!(movie.id)
      category_ids = Enum.map(loaded.categories, & &1.id)
      assert cat1.id in category_ids
      assert cat2.id in category_ids
    end

    test "creates a movie with no categories when list is empty" do
      assert {:ok, movie} = MediaCatalog.create_movie_with_categories(%{title: "Solo Movie", description: "d", poster: "/p.jpg"}, [])
      loaded = MediaCatalog.get_movie!(movie.id)
      assert loaded.categories == []
    end
  end

  describe "update_movie_with_categories/3" do
    test "replaces category associations" do
      {:ok, cat1} = Category.create_category(%{name: "Old Genre"})
      {:ok, cat2} = Category.create_category(%{name: "New Genre"})
      {:ok, movie} = MediaCatalog.create_movie_with_categories(%{title: "Movie", description: "d", poster: "/p.jpg"}, [cat1.id])

      {:ok, _} = MediaCatalog.update_movie_with_categories(movie, %{title: "Updated Movie"}, [cat2.id])
      loaded = MediaCatalog.get_movie!(movie.id)
      category_ids = Enum.map(loaded.categories, & &1.id)
      refute cat1.id in category_ids
      assert cat2.id in category_ids
    end
  end

  # ---------------------------------------------------------------------------
  # TV Series CRUD
  # ---------------------------------------------------------------------------

  describe "list_tv_series/0" do
    test "returns empty list when no series" do
      assert MediaCatalog.list_tv_series() == []
    end

    test "returns all series ordered by inserted_at desc" do
      {:ok, s1} = MediaCatalog.create_tv_series(%{title: "Series A"})
      {:ok, s2} = MediaCatalog.create_tv_series(%{title: "Series B"})
      ids = MediaCatalog.list_tv_series() |> Enum.map(& &1.id)
      assert s1.id in ids
      assert s2.id in ids
    end
  end

  describe "get_tv_series!/1" do
    test "raises Ecto.NoResultsError when series does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        MediaCatalog.get_tv_series!(-1)
      end
    end

    test "returns the series with preloaded associations" do
      {:ok, series} = MediaCatalog.create_tv_series(%{title: "Test Series"})
      loaded = MediaCatalog.get_tv_series!(series.id)
      assert loaded.id == series.id
      assert is_list(loaded.categories)
      assert is_list(loaded.seasons)
    end
  end

  describe "create_tv_series/1" do
    test "creates a series with valid attrs" do
      assert {:ok, %TVSeries{title: "New Series"}} =
               MediaCatalog.create_tv_series(%{title: "New Series"})
    end

    test "requires title" do
      assert {:error, changeset} = MediaCatalog.create_tv_series(%{})
      assert %{title: ["can't be blank"]} = errors_on(changeset)
    end

    test "enforces unique title" do
      {:ok, _} = MediaCatalog.create_tv_series(%{title: "Duplicate"})
      assert {:error, changeset} = MediaCatalog.create_tv_series(%{title: "Duplicate"})
      assert %{title: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "create_tv_series_with_categories/2" do
    test "creates series and associates given categories" do
      {:ok, cat} = Category.create_category(%{name: "Sci-Fi"})
      {:ok, series} = MediaCatalog.create_tv_series_with_categories(%{title: "Space Show"}, [cat.id])
      loaded = MediaCatalog.get_tv_series!(series.id)
      assert Enum.map(loaded.categories, & &1.id) == [cat.id]
    end
  end

  describe "update_tv_series/2" do
    test "updates series with valid attrs" do
      {:ok, series} = MediaCatalog.create_tv_series(%{title: "Old Title"})
      assert {:ok, updated} = MediaCatalog.update_tv_series(series, %{title: "New Title"})
      assert updated.title == "New Title"
    end

    test "returns error changeset on invalid attrs" do
      {:ok, series} = MediaCatalog.create_tv_series(%{title: "Valid"})
      assert {:error, changeset} = MediaCatalog.update_tv_series(series, %{title: nil})
      assert %{title: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "delete_tv_series/1" do
    test "deletes the series" do
      {:ok, series} = MediaCatalog.create_tv_series(%{title: "To Delete"})
      assert {:ok, %TVSeries{}} = MediaCatalog.delete_tv_series(series)
      assert_raise Ecto.NoResultsError, fn -> MediaCatalog.get_tv_series!(series.id) end
    end
  end

  describe "change_tv_series/2" do
    test "returns a changeset" do
      {:ok, series} = MediaCatalog.create_tv_series(%{title: "Valid"})
      assert %Ecto.Changeset{} = MediaCatalog.change_tv_series(series)
    end
  end

  describe "search_tv_series/1" do
    test "returns series matching title" do
      {:ok, _} = MediaCatalog.create_tv_series(%{title: "Breaking Bad"})
      {:ok, _} = MediaCatalog.create_tv_series(%{title: "Better Call Saul"})
      results = MediaCatalog.search_tv_series("breaking")
      assert length(results) == 1
      assert hd(results).title == "Breaking Bad"
    end

    test "returns series matching description" do
      {:ok, _} = MediaCatalog.create_tv_series(%{title: "Show A", description: "A crime drama"})
      {:ok, _} = MediaCatalog.create_tv_series(%{title: "Show B", description: "A comedy"})
      results = MediaCatalog.search_tv_series("crime")
      assert length(results) == 1
    end

    test "returns empty list when no matches" do
      {:ok, _} = MediaCatalog.create_tv_series(%{title: "Some Show"})
      assert MediaCatalog.search_tv_series("zzznomatch") == []
    end

    test "is case-insensitive" do
      {:ok, _} = MediaCatalog.create_tv_series(%{title: "The Wire"})
      results = MediaCatalog.search_tv_series("WIRE")
      assert length(results) == 1
    end
  end

  # ---------------------------------------------------------------------------
  # TV Shows (seasons)
  # ---------------------------------------------------------------------------

  describe "list_seasons_for_series/1" do
    test "returns seasons belonging to a series ordered by season_no" do
      {:ok, series} = MediaCatalog.create_tv_series(%{title: "Multi-Season Show"})

      {:ok, s2} = MediaCatalog.create_tv_show(%{title: "S2 #{System.unique_integer()}", description: "d", poster: "/p.jpg", season_no: 2, tv_series_id: series.id})
      {:ok, s1} = MediaCatalog.create_tv_show(%{title: "S1 #{System.unique_integer()}", description: "d", poster: "/p.jpg", season_no: 1, tv_series_id: series.id})

      seasons = MediaCatalog.list_seasons_for_series(series.id)
      assert length(seasons) == 2
      assert hd(seasons).id == s1.id
      assert List.last(seasons).id == s2.id
    end

    test "returns empty list when series has no seasons" do
      {:ok, series} = MediaCatalog.create_tv_series(%{title: "Empty Show"})
      assert MediaCatalog.list_seasons_for_series(series.id) == []
    end
  end

  describe "create_tv_show/1" do
    test "creates a season with valid attrs" do
      assert {:ok, %TVShow{title: "Pilot Season"}} =
               MediaCatalog.create_tv_show(%{title: "Pilot Season", description: "Pilot season", poster: "/p.jpg", season_no: 1})
    end

    test "requires title" do
      assert {:error, changeset} = MediaCatalog.create_tv_show(%{})
      assert %{title: ["can't be blank"]} = errors_on(changeset)
    end

    test "defaults season_no to 1" do
      {:ok, show} = MediaCatalog.create_tv_show(%{title: "Default Season #{System.unique_integer()}", description: "d", poster: "/p.jpg"})
      assert show.season_no == 1
    end
  end

  describe "update_tv_show/2" do
    test "updates season with valid attrs" do
      tv_show = tv_show_fixture()
      assert {:ok, updated} = MediaCatalog.update_tv_show(tv_show, %{title: "Updated Season"})
      assert updated.title == "Updated Season"
    end

    test "returns error changeset for invalid attrs" do
      tv_show = tv_show_fixture()
      assert {:error, changeset} = MediaCatalog.update_tv_show(tv_show, %{title: nil})
      assert %{title: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "delete_tv_show/1" do
    test "deletes the season" do
      tv_show = tv_show_fixture()
      assert {:ok, %TVShow{}} = MediaCatalog.delete_tv_show(tv_show)
      assert_raise Ecto.NoResultsError, fn -> MediaCatalog.get_tv_show!(tv_show.id) end
    end
  end

  # ---------------------------------------------------------------------------
  # Episodes
  # ---------------------------------------------------------------------------

  describe "list_episodes_for_season/1" do
    test "returns episodes for a season ordered by number" do
      tv_show = tv_show_fixture()
      {:ok, ep2} = MediaCatalog.create_episode(%{title: "Ep 2", number: 2, tvshow_id: tv_show.id})
      {:ok, ep1} = MediaCatalog.create_episode(%{title: "Ep 1", number: 1, tvshow_id: tv_show.id})

      episodes = MediaCatalog.list_episodes_for_season(tv_show.id)
      assert length(episodes) == 2
      assert hd(episodes).id == ep1.id
      assert List.last(episodes).id == ep2.id
    end

    test "returns empty list when season has no episodes" do
      tv_show = tv_show_fixture()
      assert MediaCatalog.list_episodes_for_season(tv_show.id) == []
    end
  end

  describe "get_episode!/1" do
    test "raises when episode does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        MediaCatalog.get_episode!(-1)
      end
    end

    test "returns the episode with preloaded associations" do
      tv_show = tv_show_fixture()
      {:ok, ep} = MediaCatalog.create_episode(%{title: "Pilot", number: 1, tvshow_id: tv_show.id})
      loaded = MediaCatalog.get_episode!(ep.id)
      assert loaded.id == ep.id
      assert loaded.tvshow.id == tv_show.id
    end
  end

  describe "create_episode/1" do
    test "creates an episode with valid attrs" do
      tv_show = tv_show_fixture()
      assert {:ok, %Episode{title: "Pilot", number: 1}} =
               MediaCatalog.create_episode(%{title: "Pilot", number: 1, tvshow_id: tv_show.id})
    end

    test "requires title and number" do
      assert {:error, changeset} = MediaCatalog.create_episode(%{})
      errors = errors_on(changeset)
      assert Map.has_key?(errors, :title)
      assert Map.has_key?(errors, :number)
    end
  end

  describe "update_episode/2" do
    test "updates episode with valid attrs" do
      tv_show = tv_show_fixture()
      {:ok, ep} = MediaCatalog.create_episode(%{title: "Old Title", number: 1, tvshow_id: tv_show.id})
      assert {:ok, updated} = MediaCatalog.update_episode(ep, %{title: "New Title"})
      assert updated.title == "New Title"
    end

    test "returns error changeset for invalid attrs" do
      tv_show = tv_show_fixture()
      {:ok, ep} = MediaCatalog.create_episode(%{title: "Valid", number: 1, tvshow_id: tv_show.id})
      assert {:error, changeset} = MediaCatalog.update_episode(ep, %{title: nil})
      assert %{title: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "delete_episode/1" do
    test "deletes the episode" do
      tv_show = tv_show_fixture()
      {:ok, ep} = MediaCatalog.create_episode(%{title: "To Delete", number: 1, tvshow_id: tv_show.id})
      assert {:ok, %Episode{}} = MediaCatalog.delete_episode(ep)
      assert_raise Ecto.NoResultsError, fn -> MediaCatalog.get_episode!(ep.id) end
    end
  end

  describe "change_episode/2" do
    test "returns a changeset for the episode" do
      tv_show = tv_show_fixture()
      {:ok, ep} = MediaCatalog.create_episode(%{title: "Ep", number: 1, tvshow_id: tv_show.id})
      assert %Ecto.Changeset{} = MediaCatalog.change_episode(ep)
    end
  end

  # ---------------------------------------------------------------------------
  # count_episodes/0
  # ---------------------------------------------------------------------------

  describe "count_episodes/0" do
    test "returns 0 when no episodes exist" do
      assert MediaCatalog.count_episodes() == 0
    end

    test "returns correct count after creating episodes" do
      tv_show = tv_show_fixture()
      {:ok, _} = MediaCatalog.create_episode(%{title: "Ep 1", number: 1, tvshow_id: tv_show.id})
      {:ok, _} = MediaCatalog.create_episode(%{title: "Ep 2", number: 2, tvshow_id: tv_show.id})
      assert MediaCatalog.count_episodes() == 2
    end

    test "decrements after deleting an episode" do
      tv_show = tv_show_fixture()
      {:ok, ep} = MediaCatalog.create_episode(%{title: "Ep", number: 1, tvshow_id: tv_show.id})
      assert MediaCatalog.count_episodes() == 1
      MediaCatalog.delete_episode(ep)
      assert MediaCatalog.count_episodes() == 0
    end
  end
end

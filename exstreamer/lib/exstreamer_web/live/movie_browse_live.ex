defmodule ExstreamerWeb.MovieBrowseLive do
  use ExstreamerWeb, :live_view

  alias Exstreamer.MediaCatalog
  alias Exstreamer.Category

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Movies")
     |> assign(:movies, MediaCatalog.list_movies())
     |> assign(:categories, Category.list_categories())
     |> assign(:active_category, nil)
     |> assign(:search, ""),
     layout: {ExstreamerWeb.Layouts, :streaming}}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    category_id = params["category"] && String.to_integer(params["category"])
    search = params["q"] || ""

    movies =
      cond do
        search != "" -> MediaCatalog.search_movies(search)
        category_id -> MediaCatalog.list_movies_by_category(category_id)
        true -> MediaCatalog.list_movies()
      end

    {:noreply,
     socket
     |> assign(:movies, movies)
     |> assign(:active_category, category_id)
     |> assign(:search, search)}
  end

  @impl true
  def handle_event("search", %{"q" => q}, socket) do
    {:noreply, push_patch(socket, to: ~p"/movies?q=#{q}")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-6 py-8">
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <h1 class="text-2xl font-black text-white">Movies</h1>
        <.search_bar value={@search} class="w-full sm:w-72" />
      </div>

      <%!-- Category filters --%>
      <div class="flex flex-wrap gap-2 mb-6">
        <.category_badge
          category={%{name: "All"}}
          active={is_nil(@active_category) && @search == ""}
          href={~p"/movies"}
        />
        <%= for cat <- @categories do %>
          <.category_badge
            category={cat}
            active={@active_category == cat.id}
            href={"#{~p"/movies"}?category=#{cat.id}"}
          />
        <% end %>
      </div>

      <%!-- Grid --%>
      <%= if Enum.empty?(@movies) do %>
        <div class="text-center py-20 text-gray-500">
          <p class="text-lg">No movies found.</p>
        </div>
      <% else %>
        <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-4">
          <%= for movie <- @movies do %>
            <.content_card item={movie} href={~p"/movies/#{movie.id}"} class="w-full" />
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end
end

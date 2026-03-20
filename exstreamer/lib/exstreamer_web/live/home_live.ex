defmodule ExstreamerWeb.HomeLive do
  use ExstreamerWeb, :live_view

  alias Exstreamer.MediaCatalog

  @impl true
  def mount(_params, _session, socket) do
    movies = MediaCatalog.list_movies()
    series = MediaCatalog.list_tv_series()
    categories = Exstreamer.Category.list_categories()

    featured = List.first(movies) || List.first(series)

    {:ok,
     socket
     |> assign(:page_title, "Home")
     |> assign(:movies, movies)
     |> assign(:series, series)
     |> assign(:categories, categories)
     |> assign(:featured, featured)
     |> assign(:featured_type, if(List.first(movies), do: "Movie", else: "Series")),
     layout: {ExstreamerWeb.Layouts, :streaming}}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%!-- Hero banner --%>
    <%= if @featured do %>
      <.hero_banner
        item={@featured}
        href={if @featured_type == "Movie", do: ~p"/movies/#{@featured.id}", else: ~p"/series/#{@featured.id}"}
        type={@featured_type}
      />
    <% else %>
      <div class="flex items-center justify-center h-64 text-gray-600">
        <p>No content yet. <a href={~p"/admin/users/log_in"} class="text-accent hover:underline">Add some from the admin panel →</a></p>
      </div>
    <% end %>

    <div class="mt-6">
      <%!-- Trending Movies --%>
      <.content_row
        title="Trending Movies"
        items={@movies}
        href_fn={fn m -> ~p"/movies/#{m.id}" end}
      />

      <%!-- Popular Series --%>
      <.content_row
        title="Popular Series"
        items={@series}
        href_fn={fn s -> ~p"/series/#{s.id}" end}
      />

      <%!-- Per-category rows --%>
      <%= for category <- @categories do %>
        <% cat_movies = Enum.filter(@movies, fn m ->
          Enum.any?(m.categories, &(&1.id == category.id))
        end) %>
        <%= if length(cat_movies) > 0 do %>
          <.content_row
            title={category.name}
            items={cat_movies}
            href_fn={fn m -> ~p"/movies/#{m.id}" end}
          />
        <% end %>
      <% end %>
    </div>
    """
  end
end

defmodule ExstreamerWeb.CategoryBrowseLive do
  use ExstreamerWeb, :live_view

  alias Exstreamer.MediaCatalog
  alias Exstreamer.Category

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    category = Category.get_category!(id)
    movies = MediaCatalog.list_movies_by_category(String.to_integer(id))
    series =
      MediaCatalog.list_tv_series()
      |> Enum.filter(fn s -> Enum.any?(s.categories, &(&1.id == String.to_integer(id))) end)

    {:ok,
     socket
     |> assign(:page_title, category.name)
     |> assign(:category, category)
     |> assign(:movies, movies)
     |> assign(:series, series),
     layout: {ExstreamerWeb.Layouts, :streaming}}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-6 py-8">
      <div class="mb-8">
        <p class="text-xs text-gray-500 uppercase tracking-widest mb-1">Category</p>
        <h1 class="text-3xl font-black text-white"><%= @category.name %></h1>
      </div>

      <%= if Enum.empty?(@movies) and Enum.empty?(@series) do %>
        <div class="text-center py-20 text-gray-500">
          <p>No content in this category yet.</p>
        </div>
      <% else %>
        <.content_row
          title="Movies"
          items={@movies}
          href_fn={fn m -> ~p"/movies/#{m.id}" end}
        />
        <.content_row
          title="Series"
          items={@series}
          href_fn={fn s -> ~p"/series/#{s.id}" end}
        />
      <% end %>
    </div>
    """
  end
end

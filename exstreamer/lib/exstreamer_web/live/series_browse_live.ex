defmodule ExstreamerWeb.SeriesBrowseLive do
  use ExstreamerWeb, :live_view

  alias Exstreamer.MediaCatalog
  alias Exstreamer.Category

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "TV Series")
     |> assign(:series, MediaCatalog.list_tv_series())
     |> assign(:categories, Category.list_categories())
     |> assign(:active_category, nil)
     |> assign(:search, ""),
     layout: {ExstreamerWeb.Layouts, :streaming}}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    category_id = params["category"] && String.to_integer(params["category"])
    search = params["q"] || ""

    series =
      cond do
        search != "" -> MediaCatalog.search_tv_series(search)
        category_id ->
          MediaCatalog.list_tv_series()
          |> Enum.filter(fn s ->
            Enum.any?(s.categories, &(&1.id == category_id))
          end)
        true -> MediaCatalog.list_tv_series()
      end

    {:noreply,
     socket
     |> assign(:series, series)
     |> assign(:active_category, category_id)
     |> assign(:search, search)}
  end

  @impl true
  def handle_event("search", %{"q" => q}, socket) do
    {:noreply, push_patch(socket, to: ~p"/series?q=#{q}")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-6 py-8">
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <h1 class="text-2xl font-black text-white">TV Series</h1>
        <.search_bar value={@search} class="w-full sm:w-72" />
      </div>

      <%!-- Category filters --%>
      <div class="flex flex-wrap gap-2 mb-6">
        <.category_badge
          category={%{name: "All"}}
          active={is_nil(@active_category) && @search == ""}
          href={~p"/series"}
        />
        <%= for cat <- @categories do %>
          <.category_badge
            category={cat}
            active={@active_category == cat.id}
            href={"#{~p"/series"}?category=#{cat.id}"}
          />
        <% end %>
      </div>

      <%= if Enum.empty?(@series) do %>
        <div class="text-center py-20 text-gray-500">
          <p class="text-lg">No series found.</p>
        </div>
      <% else %>
        <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-4">
          <%= for s <- @series do %>
            <.content_card item={s} href={~p"/series/#{s.id}"} class="w-full" />
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end
end

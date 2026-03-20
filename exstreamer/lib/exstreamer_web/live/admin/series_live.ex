defmodule ExstreamerWeb.Admin.SeriesLive do
  use ExstreamerWeb, :live_view

  alias Exstreamer.MediaCatalog
  alias Exstreamer.Category

  @upload_dir Application.app_dir(:exstreamer, "priv/uploads")

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "TV Series")
     |> assign(:series_list, MediaCatalog.list_tv_series())
     |> assign(:categories, Category.list_categories())
     |> assign(:form, nil)
     |> assign(:editing, nil)
     |> assign(:selected_categories, [])
     |> allow_upload(:poster, accept: ~w(.jpg .jpeg .png .webp), max_entries: 1, max_file_size: 10_000_000),
     layout: {ExstreamerWeb.Layouts, :admin}}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, %{assigns: %{live_action: :edit}} = socket) do
    series = MediaCatalog.get_tv_series!(id)
    changeset = MediaCatalog.change_tv_series(series)
    {:noreply,
     socket
     |> assign(:editing, series)
     |> assign(:form, to_form(changeset))
     |> assign(:selected_categories, Enum.map(series.categories, & &1.id))}
  end

  def handle_params(_params, _uri, %{assigns: %{live_action: :new}} = socket) do
    changeset = MediaCatalog.change_tv_series(%Exstreamer.MediaCatalog.TVSeries{})
    {:noreply,
     socket
     |> assign(:editing, nil)
     |> assign(:form, to_form(changeset))
     |> assign(:selected_categories, [])}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket |> assign(:form, nil) |> assign(:editing, nil)}
  end

  @impl true
  def handle_event("save", %{"tv_series" => params}, socket) do
    category_ids =
      Map.get(params, "category_ids", [])
      |> Enum.map(&String.to_integer/1)

    attrs = Map.drop(params, ["category_ids"])

    {:ok, poster_path} = maybe_upload_poster(socket)
    attrs = if poster_path, do: Map.put(attrs, "poster", poster_path), else: attrs

    result =
      case socket.assigns.editing do
        nil -> MediaCatalog.create_tv_series_with_categories(attrs, category_ids)
        series -> MediaCatalog.update_tv_series_with_categories(series, attrs, category_ids)
      end

    case result do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Series saved.")
         |> assign(:series_list, MediaCatalog.list_tv_series())
         |> push_patch(to: ~p"/admin/series")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    series = MediaCatalog.get_tv_series!(id)
    MediaCatalog.delete_tv_series(series)
    {:noreply,
     socket
     |> put_flash(:info, "Series deleted.")
     |> assign(:series_list, MediaCatalog.list_tv_series())}
  end

  def handle_event("toggle_category", %{"id" => id}, socket) do
    cat_id = String.to_integer(id)
    current = socket.assigns.selected_categories
    updated = if cat_id in current, do: List.delete(current, cat_id), else: [cat_id | current]
    {:noreply, assign(socket, :selected_categories, updated)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between mb-6">
        <h2 class="text-xl font-bold text-white">TV Series</h2>
        <.link patch={~p"/admin/series/new"}
              class="inline-flex items-center gap-2 bg-accent text-white text-sm font-semibold px-4 py-2 rounded-lg hover:bg-red-700 transition-colors">
          <.icon name="hero-plus-mini" class="w-4 h-4"/> Add Series
        </.link>
      </div>

      <%= if @form do %>
        <.modal id="series-modal" show on_cancel={JS.patch(~p"/admin/series")}>
          <h3 class="text-lg font-bold text-white mb-4">
            <%= if @editing, do: "Edit Series", else: "New Series" %>
          </h3>
          <.simple_form for={@form} phx-submit="save" class="space-y-4">
            <.input field={@form[:title]} label="Title"/>
            <.input field={@form[:description]} type="textarea" label="Description" rows="3"/>
            <.input field={@form[:rating]} type="number" step="0.1" min="0" max="10" label="IMDB Rating"/>

            <div>
              <label class="block text-sm font-medium text-gray-300 mb-2">Categories</label>
              <div class="flex flex-wrap gap-2">
                <%= for cat <- @categories do %>
                  <button type="button" phx-click="toggle_category" phx-value-id={cat.id}
                    class={"px-3 py-1 rounded-full text-xs font-semibold transition-colors #{if cat.id in @selected_categories, do: "bg-accent text-white", else: "bg-gray-700 text-gray-300 hover:bg-gray-600"}"}>
                    <%= cat.name %>
                  </button>
                <% end %>
              </div>
              <%= for cat_id <- @selected_categories do %>
                <input type="hidden" name="tv_series[category_ids][]" value={cat_id}/>
              <% end %>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-300 mb-1">Poster Image</label>
              <.live_file_input upload={@uploads.poster}
                class="block text-sm text-gray-400 file:mr-3 file:py-1.5 file:px-3 file:rounded file:border-0 file:bg-gray-700 file:text-gray-300 hover:file:bg-gray-600"/>
            </div>

            <:actions>
              <.button type="submit" class="bg-accent hover:bg-red-700 text-white">Save</.button>
              <.link patch={~p"/admin/series"} class="text-sm text-gray-400 hover:text-gray-300 ml-3">Cancel</.link>
            </:actions>
          </.simple_form>
        </.modal>
      <% end %>

      <div class="bg-gray-850 rounded-xl border border-gray-800 overflow-hidden">
        <table class="w-full text-sm">
          <thead class="border-b border-gray-800">
            <tr>
              <th class="text-left text-xs text-gray-500 uppercase tracking-wider px-4 py-3">Title</th>
              <th class="text-left text-xs text-gray-500 uppercase tracking-wider px-4 py-3 hidden md:table-cell">Seasons</th>
              <th class="text-left text-xs text-gray-500 uppercase tracking-wider px-4 py-3 hidden md:table-cell">Rating</th>
              <th class="px-4 py-3"></th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-800">
            <%= for s <- @series_list do %>
              <tr class="hover:bg-gray-800/40 transition-colors">
                <td class="px-4 py-3">
                  <div class="flex items-center gap-3">
                    <div class="w-8 h-12 rounded overflow-hidden bg-gray-800 flex-shrink-0">
                      <%= if s.poster && s.poster != "" do %>
                        <img src={"/stream/poster/#{Path.basename(s.poster)}"} class="w-full h-full object-cover"/>
                      <% end %>
                    </div>
                    <span class="font-medium text-white"><%= s.title %></span>
                  </div>
                </td>
                <td class="px-4 py-3 hidden md:table-cell text-gray-300">
                  <div class="flex items-center gap-2">
                    <span><%= length(s.seasons) %></span>
                    <a href={~p"/admin/series/#{s.id}/seasons"} class="text-xs text-accent hover:underline">Manage →</a>
                  </div>
                </td>
                <td class="px-4 py-3 hidden md:table-cell text-yellow-400">
                  <%= if s.rating, do: "★ #{Decimal.to_string(s.rating)}", else: "—" %>
                </td>
                <td class="px-4 py-3 text-right">
                  <div class="flex items-center justify-end gap-3">
                    <.link patch={~p"/admin/series/#{s.id}/edit"} class="text-xs text-gray-400 hover:text-white">Edit</.link>
                    <button phx-click="delete" phx-value-id={s.id}
                            data-confirm={"Delete #{s.title}?"}
                            class="text-xs text-red-500 hover:text-red-400">Delete</button>
                  </div>
                </td>
              </tr>
            <% end %>
            <%= if Enum.empty?(@series_list) do %>
              <tr>
                <td colspan="4" class="px-4 py-12 text-center text-gray-600">
                  No series yet. <.link patch={~p"/admin/series/new"} class="text-accent hover:underline">Add the first one →</.link>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  defp maybe_upload_poster(socket) do
    case socket.assigns.uploads.poster.entries do
      [] -> {:ok, nil}
      [entry | _] ->
        path =
          consume_uploaded_entry(socket, entry, fn %{path: tmp_path} ->
            filename = "#{System.unique_integer([:positive])}_#{entry.client_name}"
            dest = Path.join([@upload_dir, "posters", filename])
            File.cp!(tmp_path, dest)
            {:ok, dest}
          end)
        {:ok, path}
    end
  end
end

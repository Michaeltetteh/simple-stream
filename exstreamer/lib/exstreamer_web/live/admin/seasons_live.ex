defmodule ExstreamerWeb.Admin.SeasonsLive do
  use ExstreamerWeb, :live_view

  alias Exstreamer.MediaCatalog

  @upload_dir Application.app_dir(:exstreamer, "priv/uploads")

  @impl true
  def mount(%{"series_id" => series_id}, _session, socket) do
    series = MediaCatalog.get_tv_series!(series_id)

    {:ok,
     socket
     |> assign(:page_title, "Seasons — #{series.title}")
     |> assign(:series, series)
     |> assign(:seasons, MediaCatalog.list_seasons_for_series(series_id))
     |> assign(:form, nil)
     |> assign(:editing, nil)
     |> allow_upload(:poster, accept: ~w(.jpg .jpeg .png .webp), max_entries: 1, max_file_size: 10_000_000),
     layout: {ExstreamerWeb.Layouts, :admin}}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, %{assigns: %{live_action: :edit}} = socket) do
    season = MediaCatalog.get_tv_show!(id)
    changeset = MediaCatalog.change_tv_show(season)
    {:noreply, socket |> assign(:editing, season) |> assign(:form, to_form(changeset))}
  end

  def handle_params(_params, _uri, %{assigns: %{live_action: :new}} = socket) do
    changeset = MediaCatalog.change_tv_show(%Exstreamer.MediaCatalog.TVShow{})
    {:noreply, socket |> assign(:editing, nil) |> assign(:form, to_form(changeset))}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket |> assign(:form, nil) |> assign(:editing, nil)}
  end

  @impl true
  def handle_event("save", %{"tv_show" => params}, socket) do
    {:ok, poster_path} = maybe_upload_poster(socket)
    attrs =
      params
      |> Map.put("tv_series_id", socket.assigns.series.id)
      |> then(fn a -> if poster_path, do: Map.put(a, "poster", poster_path), else: a end)

    result =
      case socket.assigns.editing do
        nil -> MediaCatalog.create_tv_show(attrs)
        season -> MediaCatalog.update_tv_show(season, attrs)
      end

    case result do
      {:ok, _} ->
        series_id = socket.assigns.series.id
        {:noreply,
         socket
         |> put_flash(:info, "Season saved.")
         |> assign(:seasons, MediaCatalog.list_seasons_for_series(series_id))
         |> push_patch(to: ~p"/admin/series/#{series_id}/seasons")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    season = MediaCatalog.get_tv_show!(id)
    MediaCatalog.delete_tv_show(season)
    series_id = socket.assigns.series.id
    {:noreply,
     socket
     |> put_flash(:info, "Season deleted.")
     |> assign(:seasons, MediaCatalog.list_seasons_for_series(series_id))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center gap-2 text-sm text-gray-500 mb-1">
        <a href={~p"/admin/series"} class="hover:text-gray-300">Series</a>
        <span>/</span>
        <span class="text-gray-300"><%= @series.title %></span>
      </div>

      <div class="flex items-center justify-between mb-6">
        <h2 class="text-xl font-bold text-white">Seasons</h2>
        <.link patch={~p"/admin/series/#{@series.id}/seasons/new"}
              class="inline-flex items-center gap-2 bg-accent text-white text-sm font-semibold px-4 py-2 rounded-lg hover:bg-red-700 transition-colors">
          <.icon name="hero-plus-mini" class="w-4 h-4"/> Add Season
        </.link>
      </div>

      <%= if @form do %>
        <.modal id="season-modal" show on_cancel={JS.patch(~p"/admin/series/#{@series.id}/seasons")}>
          <h3 class="text-lg font-bold text-white mb-4">
            <%= if @editing, do: "Edit Season", else: "New Season" %>
          </h3>
          <.simple_form for={@form} phx-submit="save" class="space-y-4">
            <.input field={@form[:title]} label="Season Title"/>
            <.input field={@form[:season_no]} type="number" label="Season Number"/>
            <.input field={@form[:description]} type="textarea" label="Description" rows="2"/>
            <.input field={@form[:rating]} type="number" step="0.1" min="0" max="10" label="Rating"/>
            <div>
              <label class="block text-sm font-medium text-gray-300 mb-1">Poster</label>
              <.live_file_input upload={@uploads.poster}
                class="block text-sm text-gray-400 file:mr-3 file:py-1.5 file:px-3 file:rounded file:border-0 file:bg-gray-700 file:text-gray-300 hover:file:bg-gray-600"/>
            </div>
            <:actions>
              <.button type="submit" class="bg-accent hover:bg-red-700 text-white">Save</.button>
              <.link patch={~p"/admin/series/#{@series.id}/seasons"} class="text-sm text-gray-400 ml-3">Cancel</.link>
            </:actions>
          </.simple_form>
        </.modal>
      <% end %>

      <div class="bg-gray-850 rounded-xl border border-gray-800 overflow-hidden">
        <table class="w-full text-sm">
          <thead class="border-b border-gray-800">
            <tr>
              <th class="text-left text-xs text-gray-500 uppercase tracking-wider px-4 py-3">Season</th>
              <th class="text-left text-xs text-gray-500 uppercase tracking-wider px-4 py-3 hidden md:table-cell">Episodes</th>
              <th class="px-4 py-3"></th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-800">
            <%= for season <- @seasons do %>
              <tr class="hover:bg-gray-800/40 transition-colors">
                <td class="px-4 py-3 font-medium text-white">
                  Season <%= season.season_no %> — <%= season.title %>
                </td>
                <td class="px-4 py-3 hidden md:table-cell">
                  <div class="flex items-center gap-2 text-gray-300">
                    <span><%= length(season.episodes) %></span>
                    <a href={~p"/admin/seasons/#{season.id}/episodes"} class="text-xs text-accent hover:underline">Manage →</a>
                  </div>
                </td>
                <td class="px-4 py-3 text-right">
                  <div class="flex items-center justify-end gap-3">
                    <.link patch={~p"/admin/series/#{@series.id}/seasons/#{season.id}/edit"} class="text-xs text-gray-400 hover:text-white">Edit</.link>
                    <button phx-click="delete" phx-value-id={season.id}
                            data-confirm={"Delete Season #{season.season_no}?"}
                            class="text-xs text-red-500 hover:text-red-400">Delete</button>
                  </div>
                </td>
              </tr>
            <% end %>
            <%= if Enum.empty?(@seasons) do %>
              <tr>
                <td colspan="3" class="px-4 py-12 text-center text-gray-600">
                  No seasons yet. <.link patch={~p"/admin/series/#{@series.id}/seasons/new"} class="text-accent hover:underline">Add one →</.link>
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

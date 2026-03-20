defmodule ExstreamerWeb.Admin.MoviesLive do
  use ExstreamerWeb, :live_view

  alias Exstreamer.MediaCatalog
  alias Exstreamer.Category

  @upload_dir Application.app_dir(:exstreamer, "priv/uploads")

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Movies")
      |> assign(:movies, MediaCatalog.list_movies())
      |> assign(:categories, Category.list_categories())
      |> assign(:form, nil)
      |> assign(:editing, nil)
      |> allow_upload(:poster, accept: ~w(.jpg .jpeg .png .webp), max_entries: 1, max_file_size: 10_000_000)
      |> allow_upload(:video, accept: ~w(.mp4 .webm .mkv .mov), max_entries: 1, max_file_size: 5_000_000_000)

    {:ok, socket, layout: {ExstreamerWeb.Layouts, :admin}}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, %{assigns: %{live_action: :edit}} = socket) do
    movie = MediaCatalog.get_movie!(id)
    changeset = MediaCatalog.change_movie(movie)

    {:noreply,
     socket
     |> assign(:editing, movie)
     |> assign(:form, to_form(changeset))
     |> assign(:selected_categories, Enum.map(movie.categories, & &1.id))}
  end

  def handle_params(_params, _uri, %{assigns: %{live_action: :new}} = socket) do
    changeset = MediaCatalog.change_movie(%Exstreamer.MediaCatalog.Movie{})

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
  def handle_event("save", %{"movie" => params}, socket) do
    category_ids =
      Map.get(params, "category_ids", [])
      |> Enum.map(&String.to_integer/1)

    attrs = Map.drop(params, ["category_ids"])

    result =
      case socket.assigns.editing do
        nil ->
          with {:ok, poster_path} <- maybe_upload_poster(socket),
               {:ok, file_record} <- maybe_upload_video(socket) do
            attrs =
              attrs
              |> put_if_present("poster", poster_path)
              |> put_if_present("file_id", file_record && file_record.id)

            MediaCatalog.create_movie_with_categories(attrs, category_ids)
          end

        movie ->
          with {:ok, poster_path} <- maybe_upload_poster(socket),
               {:ok, file_record} <- maybe_upload_video(socket) do
            attrs =
              attrs
              |> put_if_present("poster", poster_path)
              |> put_if_present("file_id", file_record && file_record.id)

            MediaCatalog.update_movie_with_categories(movie, attrs, category_ids)
          end
      end

    case result do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Movie saved successfully.")
         |> assign(:movies, MediaCatalog.list_movies())
         |> push_patch(to: ~p"/admin/movies")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("validate", %{"movie" => params}, socket) do
    changeset =
      (socket.assigns.editing || %Exstreamer.MediaCatalog.Movie{})
      |> Exstreamer.MediaCatalog.Movie.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    movie = MediaCatalog.get_movie!(id)
    MediaCatalog.delete_movie(movie)

    {:noreply,
     socket
     |> put_flash(:info, "Movie deleted.")
     |> assign(:movies, MediaCatalog.list_movies())}
  end

  def handle_event("toggle_category", %{"id" => id}, socket) do
    cat_id = String.to_integer(id)
    current = socket.assigns.selected_categories

    updated =
      if cat_id in current,
        do: List.delete(current, cat_id),
        else: [cat_id | current]

    {:noreply, assign(socket, :selected_categories, updated)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between mb-6">
        <h2 class="text-xl font-bold text-white">Movies</h2>
        <.link patch={~p"/admin/movies/new"}
              class="inline-flex items-center gap-2 bg-accent text-white text-sm font-semibold px-4 py-2 rounded-lg hover:bg-red-700 transition-colors">
          <.icon name="hero-plus-mini" class="w-4 h-4"/> Add Movie
        </.link>
      </div>

      <%!-- Modal form --%>
      <%= if @form do %>
        <.modal id="movie-modal" show on_cancel={JS.patch(~p"/admin/movies")}>
          <h3 class="text-lg font-bold text-white mb-4">
            <%= if @editing, do: "Edit Movie", else: "New Movie" %>
          </h3>
          <.simple_form for={@form} phx-submit="save" phx-change="validate" class="space-y-4">
            <.input field={@form[:title]} label="Title" class="bg-gray-800 border-gray-700 text-white"/>
            <.input field={@form[:description]} type="textarea" label="Description" rows="3" class="bg-gray-800 border-gray-700 text-white"/>
            <.input field={@form[:rating]} type="number" step="0.1" min="0" max="10" label="IMDB Rating" class="bg-gray-800 border-gray-700 text-white"/>

            <%!-- Categories --%>
            <div>
              <label class="block text-sm font-medium text-gray-300 mb-2">Categories</label>
              <div class="flex flex-wrap gap-2">
                <%= for cat <- @categories do %>
                  <button
                    type="button"
                    phx-click="toggle_category"
                    phx-value-id={cat.id}
                    class={"px-3 py-1 rounded-full text-xs font-semibold transition-colors #{if cat.id in @selected_categories, do: "bg-accent text-white", else: "bg-gray-700 text-gray-300 hover:bg-gray-600"}"}
                  >
                    <%= cat.name %>
                  </button>
                <% end %>
              </div>
              <%= for cat_id <- @selected_categories do %>
                <input type="hidden" name="movie[category_ids][]" value={cat_id}/>
              <% end %>
            </div>

            <%!-- Poster upload --%>
            <div>
              <label class="block text-sm font-medium text-gray-300 mb-1">Poster Image</label>
              <.live_file_input upload={@uploads.poster}
                class="block text-sm text-gray-400 file:mr-3 file:py-1.5 file:px-3 file:rounded file:border-0 file:bg-gray-700 file:text-gray-300 hover:file:bg-gray-600"/>
              <%= for entry <- @uploads.poster.entries do %>
                <div class="mt-1 text-xs text-gray-500"><%= entry.client_name %> — <%= entry.progress %>%</div>
                <%= for err <- upload_errors(@uploads.poster, entry) do %>
                  <p class="text-red-400 text-xs"><%= error_to_string(err) %></p>
                <% end %>
              <% end %>
            </div>

            <%!-- Video upload --%>
            <div>
              <label class="block text-sm font-medium text-gray-300 mb-1">Video File</label>
              <.live_file_input upload={@uploads.video}
                class="block text-sm text-gray-400 file:mr-3 file:py-1.5 file:px-3 file:rounded file:border-0 file:bg-gray-700 file:text-gray-300 hover:file:bg-gray-600"/>
              <%= for entry <- @uploads.video.entries do %>
                <div class="mt-1 text-xs text-gray-500"><%= entry.client_name %> — <%= entry.progress %>%</div>
                <div class="w-full bg-gray-700 rounded-full h-1 mt-1">
                  <div class="bg-accent h-1 rounded-full transition-all" style={"width: #{entry.progress}%"}></div>
                </div>
              <% end %>
            </div>

            <:actions>
              <.button type="submit" class="bg-accent hover:bg-red-700 text-white">Save</.button>
              <.link patch={~p"/admin/movies"} class="text-sm text-gray-400 hover:text-gray-300 ml-3">Cancel</.link>
            </:actions>
          </.simple_form>
        </.modal>
      <% end %>

      <%!-- Movies table --%>
      <div class="bg-gray-850 rounded-xl border border-gray-800 overflow-hidden">
        <table class="w-full text-sm">
          <thead class="border-b border-gray-800">
            <tr>
              <th class="text-left text-xs text-gray-500 uppercase tracking-wider px-4 py-3">Title</th>
              <th class="text-left text-xs text-gray-500 uppercase tracking-wider px-4 py-3 hidden md:table-cell">Rating</th>
              <th class="text-left text-xs text-gray-500 uppercase tracking-wider px-4 py-3 hidden lg:table-cell">Categories</th>
              <th class="text-left text-xs text-gray-500 uppercase tracking-wider px-4 py-3 hidden md:table-cell">Video</th>
              <th class="px-4 py-3"></th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-800">
            <%= for movie <- @movies do %>
              <tr class="hover:bg-gray-800/40 transition-colors">
                <td class="px-4 py-3">
                  <div class="flex items-center gap-3">
                    <div class="w-8 h-12 rounded overflow-hidden bg-gray-800 flex-shrink-0">
                      <%= if movie.poster && movie.poster != "" do %>
                        <img src={"/stream/poster/#{Path.basename(movie.poster)}"} class="w-full h-full object-cover"/>
                      <% end %>
                    </div>
                    <span class="font-medium text-white"><%= movie.title %></span>
                  </div>
                </td>
                <td class="px-4 py-3 hidden md:table-cell text-yellow-400">
                  <%= if movie.rating, do: "★ #{Decimal.to_string(movie.rating)}", else: "—" %>
                </td>
                <td class="px-4 py-3 hidden lg:table-cell">
                  <div class="flex flex-wrap gap-1">
                    <%= for cat <- movie.categories do %>
                      <span class="px-2 py-0.5 bg-gray-700 text-gray-300 rounded text-xs"><%= cat.name %></span>
                    <% end %>
                  </div>
                </td>
                <td class="px-4 py-3 hidden md:table-cell text-gray-500">
                  <%= if movie.file, do: "✓", else: "—" %>
                </td>
                <td class="px-4 py-3 text-right">
                  <div class="flex items-center justify-end gap-3">
                    <.link patch={~p"/admin/movies/#{movie.id}/edit"}
                          class="text-xs text-gray-400 hover:text-white transition-colors">Edit</.link>
                    <button phx-click="delete" phx-value-id={movie.id}
                            data-confirm={"Delete #{movie.title}?"}
                            class="text-xs text-red-500 hover:text-red-400 transition-colors">Delete</button>
                  </div>
                </td>
              </tr>
            <% end %>
            <%= if Enum.empty?(@movies) do %>
              <tr>
                <td colspan="5" class="px-4 py-12 text-center text-gray-600">
                  No movies yet. <.link patch={~p"/admin/movies/new"} class="text-accent hover:underline">Add the first one →</.link>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  # ── Upload helpers ────────────────────────────────────────────────────────────

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

  defp maybe_upload_video(socket) do
    case socket.assigns.uploads.video.entries do
      [] -> {:ok, nil}
      [entry | _] ->
        path =
          consume_uploaded_entry(socket, entry, fn %{path: tmp_path} ->
            filename = "#{System.unique_integer([:positive])}_#{entry.client_name}"
            dest = Path.join([@upload_dir, "videos", filename])
            File.cp!(tmp_path, dest)
            {:ok, dest}
          end)

        case MediaCatalog.create_media_file(%{
               name: entry.client_name,
               path: path,
               size: entry.client_size,
               type: entry.client_type
             }) do
          {:ok, file} -> {:ok, file}
          err -> err
        end
    end
  end

  defp put_if_present(attrs, _key, nil), do: attrs
  defp put_if_present(attrs, key, value), do: Map.put(attrs, key, value)

  defp error_to_string(:too_large), do: "File too large"
  defp error_to_string(:not_accepted), do: "File type not accepted"
  defp error_to_string(:too_many_files), do: "Too many files"
  defp error_to_string(err), do: inspect(err)
end

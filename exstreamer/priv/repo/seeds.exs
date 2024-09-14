# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Exstreamer.Repo.insert!(%Exstreamer.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# priv/repo/seeds.exs

alias Exstreamer.MediaCatalog
# alias Exstreamer.MediaCatalog.Category

categories = [ "Comedy", "Action", "Drama", "Horror", "Sci-Fi", "Documentary" ]

categories
|> Enum.each(fn category ->
  case MediaCatalog.get_category_by_name(category) do
    nil -> 
      case MediaCatalog.create_category(%{name: category}) do
        {:ok, _category} -> IO.puts("Inserted '#{category}'")
        {:error, changeset} -> IO.puts("Failed to insert '#{category}': #{inspect(changeset.errors)}")
      end
    _existing -> 
      IO.puts("Category '#{category}' already exists.")
  end
end)

IO.puts("Categories have been seeded.")

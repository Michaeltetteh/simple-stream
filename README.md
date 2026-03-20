# simple-stream
Simple web streaming service implemented in Elixir/Pheonix

## Installation
* [pheonix installation guide](https://hexdocs.pm/phoenix/installation.html)

## Run

  ```
  $ docker compose up
  
  $ cd exstreamer

  $ mix ecto.migrate

  $ mix phx.server
  
  ```

## Test

  ```
  $ docker compose up

  $ cd exstreamer

  $ mix test
  ```

The test suite covers:
- **Context layer** — `Exstreamer.Accounts`, `Exstreamer.Category`, `Exstreamer.MediaCatalog` (movies, TV series, seasons, episodes, files)
- **LiveView (public)** — `HomeLive`, `MovieBrowseLive`, `MovieDetailLive`, `SeriesBrowseLive`, `SeriesDetailLive`, `CategoryBrowseLive`, `SearchLive`, `EpisodePlayerLive`
- **LiveView (admin)** — `DashboardLive`, `MoviesLive`, `CategoriesLive`
- **Controllers** — user authentication (registration, login, session, settings, password reset, confirmation)
- **Auth middleware** — `UserAuth` plug and LiveView on-mount hooks
# Exstreamer

A self-hosted, Netflix-style video streaming platform built with Phoenix LiveView, Elixir, PostgreSQL, and Tailwind CSS.

---

## Features

- **Dark Netflix-style UI** — hero banner, horizontal card rows, card hover effects
- **Movies** — upload poster + video file, assign categories, IMDB rating, full video player with seek support
- **TV Series** — organised as `Series → Seasons → Episodes`; season tab switcher on detail page
- **Episode Player** — in-season prev/next navigation, breadcrumb trail
- **Search** — debounced full-text search across movies and series
- **Category Browsing** — filter grid by genre/category; cards push-patch URL without page reload
- **HTTP Range Streaming** — `206 Partial Content` responses so users can seek/scrub without downloading the whole file
- **File Storage** — local filesystem (`priv/uploads/videos/`, `priv/uploads/posters/`); no S3 required
- **Admin Panel** — dark sidebar layout with CRUD for movies, series, seasons, episodes, and categories; file upload with progress bar
- **Open Access** — public browsing/watching requires no login; admin panel requires authentication

---

## Architecture

```
Exstreamer
├── Contexts
│   ├── Exstreamer.Accounts        — user auth (email/password, tokens)
│   ├── Exstreamer.MediaCatalog    — movies, TV series, seasons, episodes, files
│   └── Exstreamer.Category        — genre/category management
│
├── Schemas
│   ├── users                      — email, hashed_password
│   ├── movies                     — title, description, rating, poster, file_id FK
│   ├── tv_series                  — parent show (title, description, rating, poster)
│   ├── tvshows                    — season (season_no, poster; belongs to tv_series)
│   ├── episodes                   — title, number, released_date, file FK
│   ├── files                      — name, path, size, type (video/image metadata)
│   └── categories                 — name (unique)
│
├── Public LiveViews (streaming layout)
│   ├── HomeLive           /
│   ├── MovieBrowseLive    /movies
│   ├── MovieDetailLive    /movies/:id
│   ├── SeriesBrowseLive   /series
│   ├── SeriesDetailLive   /series/:id
│   ├── EpisodePlayerLive  /series/:id/season/:sid/episode/:eid
│   ├── SearchLive         /search
│   └── CategoryBrowseLive /categories/:id
│
├── Admin LiveViews (admin layout, require auth)
│   ├── Admin.DashboardLive    /admin/dashboard
│   ├── Admin.MoviesLive       /admin/movies
│   ├── Admin.SeriesLive       /admin/series
│   ├── Admin.SeasonsLive      /admin/series/:id/seasons
│   ├── Admin.EpisodesLive     /admin/seasons/:id/episodes
│   └── Admin.CategoriesLive   /admin/categories
│
└── Controllers
    ├── StreamController   /stream/video/:file_id   (Range-request video)
    │                      /stream/poster/:filename  (image serving)
    └── Auth controllers   /admin/users/*
```

---

## Database Relationships

```
users
  └─< movies (uploaded_by)
  └─< tv_series (uploaded_by)
  └─< tvshows (uploaded_by)

tv_series
  └─< tvshows (seasons)  tv_series_id FK
       └─< episodes      tvshow_id FK
                          └── files  file FK

movies ──── files  (file_id FK)

categories >──< movies      (movie_categories join table)
categories >──< tvshows     (tvshow_categories join table)
categories >──< tv_series   (tv_series_categories join table)
```

---

## Setup

### 1. Prerequisites
- Elixir 1.14+, Erlang 25+
- PostgreSQL (via Docker or local install)

### 2. Start the database

```bash
cd /path/to/simple-stream
docker compose up -d
```

Default credentials (matches `config/dev.exs`):
- User: `postgres`
- Password: `mysecretpassword`
- Host: `localhost:5432`

### 3. Install dependencies & run migrations

```bash
cd exstreamer
mix deps.get
mix ecto.create
mix ecto.migrate
```

### 4. Start the server

```bash
mix phx.server
```

Visit [http://localhost:4000](http://localhost:4000)

### 5. Create an admin account

Visit [http://localhost:4000/admin/users/register](http://localhost:4000/admin/users/register) to create your admin account.

---

## Admin Guide

1. **Log in** at `/admin/users/log_in`
2. **Add Categories** at `/admin/categories` — create genres (Action, Comedy, Drama…)
3. **Add Movies** at `/admin/movies` — upload a poster image + video file, assign categories, set IMDB rating
4. **Add TV Series** at `/admin/series` — create the parent show entry with poster + categories
5. **Add Seasons** — from the series row click "Manage →" or go to `/admin/series/:id/seasons`
6. **Add Episodes** — from the season row click "Manage →" or go to `/admin/seasons/:id/episodes` — upload a video file per episode

---

## Video Streaming Notes

The `StreamController` serves video files with full **HTTP Range Request** support:

- Client sends `Range: bytes=start-end` header
- Server responds `206 Partial Content` with `Content-Range` and the byte slice
- This allows HTML5 `<video>` to seek/scrub without re-downloading the file
- Files are stored in `priv/uploads/videos/`; posters in `priv/uploads/posters/`
- Supported formats: `.mp4`, `.webm`, `.mkv`, `.mov`

### File size limits (configurable in LiveView `allow_upload`):
| Type    | Limit |
|---------|-------|
| Poster  | 10 MB |
| Video   | 5 GB  |

---

## Directory Structure

```
lib/
├── exstreamer/               # Domain logic
│   ├── accounts.ex           # User auth context
│   ├── category.ex           # Categories context
│   ├── media_catalog.ex      # Central media context
│   └── media_catalog/        # Ecto schemas
├── exstreamer_web/
│   ├── components/
│   │   ├── core_components.ex
│   │   ├── streaming_components.ex  # Shared streaming UI (cards, hero, player…)
│   │   └── layouts/
│   │       ├── root.html.heex       # Dark base HTML shell
│   │       ├── streaming.html.heex  # Public nav + main wrapper
│   │       ├── admin.html.heex      # Sidebar admin layout
│   │       └── app.html.heex        # Auth pages (login/register)
│   ├── controllers/
│   │   └── stream_controller.ex    # Range-request video + poster serving
│   └── live/
│       ├── home_live.ex
│       ├── movie_browse_live.ex
│       ├── movie_detail_live.ex
│       ├── series_browse_live.ex
│       ├── series_detail_live.ex
│       ├── episode_player_live.ex
│       ├── search_live.ex
│       ├── category_browse_live.ex
│       └── admin/
│           ├── dashboard_live.ex
│           ├── movies_live.ex
│           ├── series_live.ex
│           ├── seasons_live.ex
│           ├── episodes_live.ex
│           └── categories_live.ex
priv/
└── uploads/
    ├── videos/    # Uploaded video files
    └── posters/   # Uploaded poster images
```

---

## Tech Stack

| Layer      | Technology                      |
|------------|---------------------------------|
| Language   | Elixir ~> 1.14                  |
| Framework  | Phoenix 1.7.14 + LiveView 1.0   |
| Database   | PostgreSQL via Ecto             |
| Auth       | bcrypt_elixir + session tokens  |
| CSS        | Tailwind CSS v3.4               |
| JS         | Phoenix LiveView JS + topbar    |
| HTTP       | Bandit                          |
| Email      | Swoosh (local dev mailbox)      |


Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

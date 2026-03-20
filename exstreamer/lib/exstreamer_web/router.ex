defmodule ExstreamerWeb.Router do
  use ExstreamerWeb, :router

  import ExstreamerWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ExstreamerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # ─── Public streaming pages (open access) ─────────────────────────────────
  scope "/", ExstreamerWeb do
    pipe_through :browser

    live_session :public,
      on_mount: [{ExstreamerWeb.UserAuth, :mount_current_user}] do
      live "/", HomeLive, :index
      live "/movies", MovieBrowseLive, :index
      live "/movies/:id", MovieDetailLive, :show
      live "/series", SeriesBrowseLive, :index
      live "/series/:id", SeriesDetailLive, :show
      live "/series/:series_id/season/:season_id/episode/:episode_id", EpisodePlayerLive, :show
      live "/search", SearchLive, :index
      live "/categories/:id", CategoryBrowseLive, :index
    end
  end

  # ─── Video / image streaming ───────────────────────────────────────────────
  scope "/stream", ExstreamerWeb do
    pipe_through :browser

    get "/video/:file_id", StreamController, :video
    get "/poster/:filename", StreamController, :poster
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:exstreamer, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ExstreamerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  # ─── Admin — unauthenticated (login / register) ───────────────────────────
  scope "/admin", ExstreamerWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  # ─── Admin — authenticated ─────────────────────────────────────────────────
  scope "/admin", ExstreamerWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email

    live_session :admin,
      on_mount: [{ExstreamerWeb.UserAuth, :ensure_authenticated}] do
      live "/dashboard", Admin.DashboardLive, :index
      live "/movies", Admin.MoviesLive, :index
      live "/movies/new", Admin.MoviesLive, :new
      live "/movies/:id/edit", Admin.MoviesLive, :edit
      live "/series", Admin.SeriesLive, :index
      live "/series/new", Admin.SeriesLive, :new
      live "/series/:id/edit", Admin.SeriesLive, :edit
      live "/series/:series_id/seasons", Admin.SeasonsLive, :index
      live "/series/:series_id/seasons/new", Admin.SeasonsLive, :new
      live "/series/:series_id/seasons/:id/edit", Admin.SeasonsLive, :edit
      live "/seasons/:season_id/episodes", Admin.EpisodesLive, :index
      live "/seasons/:season_id/episodes/new", Admin.EpisodesLive, :new
      live "/seasons/:season_id/episodes/:id/edit", Admin.EpisodesLive, :edit
      live "/categories", Admin.CategoriesLive, :index
      live "/categories/new", Admin.CategoriesLive, :new
      live "/categories/:id/edit", Admin.CategoriesLive, :edit
    end
  end

  # ─── Admin — session-only (no auth plug) ──────────────────────────────────
  scope "/admin", ExstreamerWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end
end

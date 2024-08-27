defmodule Exstreamer.Repo do
  use Ecto.Repo,
    otp_app: :exstreamer,
    adapter: Ecto.Adapters.Postgres
end

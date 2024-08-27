defmodule Exstreamer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ExstreamerWeb.Telemetry,
      Exstreamer.Repo,
      {DNSCluster, query: Application.get_env(:exstreamer, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Exstreamer.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Exstreamer.Finch},
      # Start a worker by calling: Exstreamer.Worker.start_link(arg)
      # {Exstreamer.Worker, arg},
      # Start to serve requests, typically the last entry
      ExstreamerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exstreamer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ExstreamerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

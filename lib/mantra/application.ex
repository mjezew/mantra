defmodule Mantra.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Redix, host: "localhost", port: 6379, name: :redix},
      {Garf.GraphCache,
       redix: :redix,
       nodes: %{"Page" => Mantra.Contents.Page, "Block" => Mantra.Contents.Block},
       edges: %{"BELONGS_TO" => Mantra.Contents.BelongsTo}},
      # Start the Telemetry supervisor
      MantraWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Mantra.PubSub},
      # Start the Endpoint (http/https)
      MantraWeb.Endpoint
      # Start a worker by calling: Mantra.Worker.start_link(arg)
      # {Mantra.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mantra.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MantraWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

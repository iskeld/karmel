defmodule Karmel.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = 4001

    # List all child processes to be supervised
    children = [
      Karmel.Config,
      Plug.Adapters.Cowboy.child_spec(:http, Karmel.Web.Handler, [], port: port)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Karmel.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

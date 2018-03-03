defmodule Karmel.Web.Plug do
  use Plug.Builder

  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison

  plug Karmel.Web.TokenValidator

  plug Karmel.Web.Handler
end

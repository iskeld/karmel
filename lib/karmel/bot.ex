defmodule Karmel.Bot do
  @callback start_link(Karmel.Team.t()) :: GenServer.on_start()
  @callback handle(pid(), Karmel.Command.t()) :: :ok
end

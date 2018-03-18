defmodule Karmel.BotImpl do
  use GenServer

  @behaviour Karmel.Bot

  def start_link(args = %Karmel.Team{team_id: team_id}) do
    GenServer.start_link(__MODULE__, args, name: Karmel.BotRegistry.register(team_id))
  end

  def handle(pid, cmd) do
    GenServer.cast(pid, {:cmd, cmd})
  end

  def init(args) do
    {:ok, args}
  end

  def handle_cast({:cmd, cmd}, state) do
    IO.inspect(cmd)
    {:noreply, state}
  end
end

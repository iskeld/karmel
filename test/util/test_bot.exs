defmodule Karmel.Test.Util.TestBot do
  use GenServer

  @behaviour Karmel.Bot

  def start_link(args = %Karmel.Team{team_id: team_id}) do
    GenServer.start_link(__MODULE__, args, name: Karmel.BotRegistry.register(team_id))
  end

  def handle(pid, cmd) do
    GenServer.cast(pid, {:cmd, cmd})
  end

  def get_requests(pid) do
    GenServer.call(pid, :get)
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:cmd, cmd}, state) do
    {:noreply, [cmd | state]}
  end

  def init(_) do
    {:ok, []}
  end
end

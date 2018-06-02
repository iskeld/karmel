defmodule Karmel.BotRegistry do
  @spec child_spec :: {module(), keyword()}
  def child_spec() do
    {Registry, keys: :unique, name: __MODULE__}
  end

  @spec lookup(Karmel.Request.teamid()) :: {:ok, pid()} | :not_found
  def lookup(team_id) do
    case Registry.lookup(__MODULE__, team_id) do
      [{pid, _}] -> {:ok, pid}
      _ -> :not_found
    end
  end

  @spec register(Karmel.Request.teamid()) :: {:via, module(), {atom(), Karmel.Request.teamid()}}
  def register(team_id) do
    {:via, Registry, {__MODULE__, team_id}}
  end
end

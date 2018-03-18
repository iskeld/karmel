defmodule Karmel.BotRegistry do
  def child_spec() do
    {Registry, keys: :unique, name: __MODULE__}
  end

  def lookup(team_id) do
    case Registry.lookup(__MODULE__, team_id) do
      [{pid, _}] -> {:ok, pid}
      _ -> :not_found
    end
  end

  def register(team_id) do
    {:via, Registry, {__MODULE__, team_id}}
  end
end

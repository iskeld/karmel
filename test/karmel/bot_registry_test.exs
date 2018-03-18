defmodule Karmel.BotRegistryTest do
  import Karmel.BotRegistry
  use ExUnit.Case, async: true

  test "correct child_spec" do
    assert child_spec() == {Registry, keys: :unique, name: Karmel.BotRegistry}
  end

  test "correct registration" do
    team_id = "T4234"
    assert register(team_id) == {:via, Registry, {Karmel.BotRegistry, team_id}}
  end

  test "returns nil for nonexistent team" do
    assert lookup("T432") == :not_found
  end

  test "returns pid for registered team" do
    team_id = "T432"
    {:ok, pid} = Agent.start(fn -> [] end, name: register(team_id))
    lookup_pid = lookup(team_id)
    Agent.stop(pid)

    assert lookup_pid == {:ok, pid}
  end
end

defmodule Karmel.BotServerTest do
  use ExUnit.Case, async: true

  alias Karmel.Request
  import Karmel.BotServer
  import ExUnit.CaptureLog

  @team_id "T0001"

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Karmel.Repo)
    add_team(@team_id)
    :ok
  end

  defp get_request(team_id) do
    %Request{team_id: team_id}
  end

  defp add_team(team_id) do
    %Karmel.Team{team_id: team_id, name: "test", token: ""} |> Karmel.Repo.insert!()
  end

  test "logs for non existing team" do
    team_id = "T0002"
    req = get_request(team_id)
    assert capture_log(fn -> dispatch_request(req) end) =~ "Team #{team_id} does not exist"
  end

  test "spawns new bot" do
    req = get_request(@team_id)
    {:ok, pid} = dispatch_request(req)

    assert %{active: 1} = Karmel.BotsSupervisor.count_children()
    GenServer.stop(pid)
  end

  test "multiple calls reuse bots" do
    req = get_request(@team_id)
    {:ok, pid} = dispatch_request(req)
    {:ok, pid2} = dispatch_request(req)

    assert pid == pid2
    assert %{active: 1} = Karmel.BotsSupervisor.count_children()
    GenServer.stop(pid)
  end

  test "dispatches command to bot" do
    req = %{get_request(@team_id) | text: "<@u01> ++"}
    {:ok, pid} = dispatch_request(req)
    {:ok, ^pid} = dispatch_request(%{req | text: "<@u02> --"})

    commands = Karmel.Test.Util.TestBot.get_requests(pid)

    assert [%Request{text: "<@u02> --"}, %Request{text: "<@u01> ++"}] = commands
  end
end

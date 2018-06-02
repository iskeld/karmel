defmodule Karmel.BotServerTest do
  use ExUnit.Case, async: false

  alias Karmel.Request
  import Karmel.BotServer
  import ExUnit.CaptureLog
  import Mox

  @team_id "T0001"


  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Karmel.Repo)
    verify_on_exit!()
    add_team(@team_id)
    :ok
  end

  defp get_request(team_id) do
    %Request{team_id: team_id}
  end

  defp add_team(team_id) do
    %Karmel.Team{team_id: team_id, name: "test", token: ""} |> Karmel.Repo.insert!()
  end

  defp pass_auth_test() do
    Karmel.Test.Util.TestSlackApi
    |> expect(:auth_test, fn x -> {:ok, %{}} end)
  end

  defp kill_bot(pid) do
    :ok = Karmel.BotsSupervisor.terminate_child(pid)
  end

  test "returns error for non existing team" do
    team_id = "T0002"
    req = get_request(team_id)
    assert {:error, msg} = dispatch_request(req)
    assert msg =~ "Team #{team_id} does not exist"
    assert %{active: 0} = Karmel.BotsSupervisor.count_children()
  end

  test "returns error for failed auth" do
    Karmel.Test.Util.TestSlackApi
    |> expect(:auth_test, fn x -> {:error, "Auth failed"} end)

    req = get_request(@team_id)
    assert {:error, msg} = dispatch_request(req)
    assert msg =~ "Auth failed"
    assert %{active: 0} = Karmel.BotsSupervisor.count_children()
  end

  test "spawns new bot" do
    pass_auth_test()
    req = get_request(@team_id)
    {:ok, pid} = dispatch_request(req)

    assert %{active: 1} = Karmel.BotsSupervisor.count_children()
    kill_bot(pid)
  end

  test "multiple calls reuse bots" do
    pass_auth_test()
    req = get_request(@team_id)
    {:ok, pid} = dispatch_request(req)
    {:ok, pid2} = dispatch_request(req)

    assert pid == pid2
    assert %{active: 1} = Karmel.BotsSupervisor.count_children()
    kill_bot(pid)
  end

  test "dispatches command to bot" do
    pass_auth_test()
    req = %{get_request(@team_id) | text: "<@u01> ++"}
    {:ok, pid} = dispatch_request(req)
    {:ok, ^pid} = dispatch_request(%{req | text: "<@u02> --"})

    commands = Karmel.Test.Util.TestBot.get_requests(pid)

    assert [%Request{text: "<@u02> --"}, %Request{text: "<@u01> ++"}] = commands
    kill_bot(pid)
  end
end

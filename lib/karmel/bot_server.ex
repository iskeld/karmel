defmodule Karmel.BotServer do
  require Logger
  alias Karmel.Request

  @bot Application.get_env(:karmel, :bot)
  @slack_api Application.get_env(:karmel, :slack_api)

  @spec dispatch_request(Karmel.Request.t()) :: {:ok, pid()} | {:error, String.t()}
  def dispatch_request(req = %Request{team_id: team_id}) do
    bot_result =
      case Karmel.BotRegistry.lookup(team_id) do
        {:ok, pid} -> {:ok, pid}
        :not_found -> spawn_bot(team_id)
      end

    case bot_result do
      {:ok, pid} ->
        @bot.handle(pid, req)
        {:ok, pid}

      {:error, msg} -> {:error, msg}
    end
  end

  @spec spawn_bot(String.t()) :: {:ok, pid()} | {:error, String.t()}
  def spawn_bot(team_id) do
    with {:ok, team} <- load_team(team_id),
         {:ok, slack_data} <- @slack_api.auth_test(team.token) do
      case Karmel.BotsSupervisor.start_child({@bot, team}) do
        {:ok, pid} ->
          {:ok, pid}

        {:error, {:already_started, pid}} ->
          {:ok, pid}

        err ->
          {:error, "Error in spawn_bot for team #{team_id}: #{inspect(err)}"}
      end
    else
      {:error, :not_found} ->
        {:error, "Team #{team_id} does not exist"}

      {:error, msg} ->
        {:error, "Cannot retrieve team (#{team_id}) data: #{msg}"}

      err ->
        {:error, "Error in spawn_bot for team #{team_id}: #{inspect(err)}"}
    end
  end

  @spec load_team(String.t()) :: {:ok, Ecto.Schema.t()} | {:error, :not_found}
  defp load_team(team_id) do
    case Karmel.Team.get_by_team_id(team_id, true) do
      nil -> {:error, :not_found}
      team -> {:ok, team}
    end
  end
end

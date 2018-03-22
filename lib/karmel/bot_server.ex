defmodule Karmel.BotServer do
  require Logger
  alias Karmel.Request

  @bot Application.get_env(:karmel, :bot)

  @spec dispatch_request(Karmel.Request.t()) :: {:ok, pid()} | :error
  def dispatch_request(req = %Request{team_id: team_id}) do
    bot_pid = case Karmel.BotRegistry.lookup(team_id) do
      {:ok, pid} -> pid
      :not_found -> spawn_bot(team_id)
    end

    if bot_pid != nil do
      @bot.handle(bot_pid, req)
      {:ok, bot_pid}
    else
      :error
    end
  end

  def spawn_bot(team_id) do
    team = Karmel.Team.get_by_team_id(team_id, true)
    if team != nil do
      case Karmel.BotsSupervisor.start_child({@bot, team}) do
        {:ok, pid} -> pid
        {:error, {:already_started, pid}} -> pid
        err -> 
          Logger.error("Cannot start team #{team_id}. Error: #{inspect(err)}")
          nil
      end
    else
      Logger.warn("Team #{team_id} does not exist")
      nil
    end
  end
end
